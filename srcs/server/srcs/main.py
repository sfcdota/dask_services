import signal
from dask_kubernetes import KubeCluster, make_pod_spec
import time
import dask
import os
from pathlib import Path
from dask.distributed import Client


def init_directories():
    ftps = os.getenv("FTPS_DIR")
    csv = os.getenv("CSV_DIR")
    system = os.getenv("SYSTEM_DIR")
    results = os.getenv("RESULTS_DIR")
    scheduler_file = os.getenv("SCHEDULER_FILE_DIR")
    Path(f"{ftps}").mkdir(parents=True, exist_ok=True)
    Path(f"{csv}").mkdir(parents=True, exist_ok=True)
    Path(f"{results}").mkdir(parents=True, exist_ok=True)
    Path(f"{system}").mkdir(parents=True, exist_ok=True)
    Path(f"{scheduler_file}").mkdir(parents=True, exist_ok=True)
    return ftps, csv, system, results, scheduler_file


def close_cluster():
    cluster.close()

def receiveSignal(sigNum, frame):
    close_cluster()
    exit(0)


signal.signal(signal.SIGINT, receiveSignal)
signal.signal(signal.SIGQUIT, receiveSignal)
signal.signal(signal.SIGTERM, receiveSignal)

pip_packages = 'git+https://github.com/sfcdota/dask-kubernetes@main dask==2021.04.1 distributed==2021.04.1'

ftps_dir, csv_dir, system_dir, results_dir, scheduler_file_dir = init_directories()


extra_container_spec = {
    "volumeMounts":
        [
                {
                    "name": "calc-persistent-storage",
                    "mountPath": ftps_dir
                }
        ]
}


extra_pod_spec = {
    "volumes":
        [
            {
                "name": "calc-persistent-storage",
                "persistentVolumeClaim":
                    {
                        "claimName": "calc-pvc"
                    }
            }
        ],
    "terminationGracePeriodSeconds": 15,
    "nodeSelector": {'cloud.google.com/gke-nodepool': "dask"},
    "topologySpreadConstraints":
    [
        {
            "maxSkew": 1,
            "labelSelector":
                {
                    "dask.org/component": "worker"
                },
            "topologyKey": "kubernetes.io/hostname",
            "whenUnsatisfiable": "DoNotSchedule",
        },
    ]
}

extra_pod_spec_scheduler = {
    "volumes":
        [
            {
                "name": "calc-persistent-storage",
                "persistentVolumeClaim":
                    {
                        "claimName": "calc-pvc",
                    }
            },
        ],
    "nodeSelector": {'cloud.google.com/gke-nodepool': "default-pool"},
    "terminationGracePeriodSeconds": 15,
}


# dask.config.set(
#     {'distributed.worker.memory.target': 0.8,
#      'distributed.worker.memory.spill': 0.85,
#      'distributed.worker.memory.pause':0.9,
#      'distributed.worker.memory.terminate':0.95,}
# )

while True:
    worker_num = 16
    cpu_num = 16 / worker_num
    memory = 55296 * 2 / worker_num
    threads = max(round(cpu_num), 1)
    pod_spec = make_pod_spec(image='daskdev/dask:2021.4.1',
                             memory_limit='60Gi', memory_request='16Mi',
                             cpu_limit=cpu_num, cpu_request=0.001, env={'EXTRA_PIP_PACKAGES': pip_packages},
                             extra_container_config=extra_container_spec, threads_per_worker=threads,
                             extra_pod_config=extra_pod_spec)
    scheduler = make_pod_spec(image='daskdev/dask:2021.4.1',
                              memory_limit='23Gi', memory_request='16Mi',
                              cpu_limit=5.5, cpu_request=0.001, env={'EXTRA_PIP_PACKAGES': pip_packages},
                              extra_container_config=extra_container_spec, threads_per_worker=8,
                              extra_pod_config=extra_pod_spec_scheduler
                              )
    cluster = KubeCluster(scheduler_pod_template=scheduler, pod_template=pod_spec, n_workers=worker_num,
                          deploy_mode="remote", scheduler_service_wait_timeout=300, env={'EXTRA_PIP_PACKAGES': pip_packages},
                          name="dask")
    print(dask.config.config)
    # cluster.adapt(minimum=worker_num, maximum=worker_num)
    try:
        time.sleep(10)
        with open(f"{scheduler_file_dir}/.scheduler", "w") as scheduler:
            scheduler.write(str(cluster.scheduler_address))
        with open(f"{scheduler_file_dir}/.dashboard", "w") as dashboard:
            dashboard.write(str(cluster.dashboard_link))
            dashboard.write("\nDask config:\n"+str(dask.config.config))
    except OSError:
        close_cluster()
        exit(1)
    while True:
        try:
            cluster.get_logs(cluster=False, scheduler=True, workers=False)
            time.sleep(75)
        except BaseException:
            close_cluster()
            print("Scheduler is dead. Restarting cluster...")
            time.sleep(10.0)
            break

