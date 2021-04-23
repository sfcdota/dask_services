import difflib
import signal
from dask_kubernetes import KubeCluster, make_pod_spec
import time
import dask
import os
from pathlib import Path


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


def receiveSignal(sigNum, frame):
    os.remove(cluster.scheduler_address)
    cluster.close()
    exit(0)


signal.signal(signal.SIGINT, receiveSignal)
signal.signal(signal.SIGQUIT, receiveSignal)

pip_packages = 'git+https://github.com/dask/dask-kubernetes@main git+https://github.com/dask/distributed@main \
    git+https://github.com/dask/dask@main'
ftps_dir, csv_dir, system_dir, results_dir, scheduler_file_dir = init_directories()
extra_container_spec = {
    "volumeMounts":
        [
                {
                    "name": "ftps-persistent-storage",
                    "mountPath": ftps_dir
                }
        ]
}


extra_pod_spec = {
    "volumes":
        [
            {
                "name": "ftps-persistent-storage",
                "persistentVolumeClaim":
                    {
                        "claimName": "ftps-pv-claim"
                    }
            }
        ]
}

pod_spec = make_pod_spec(image='daskdev/dask:latest',
                         memory_limit='0.5G', memory_request='0.5G',
                         cpu_limit=0.5, cpu_request=0.5, threads_per_worker=1,
                         env={'EXTRA_PIP_PACKAGES': pip_packages},
                         extra_container_config=extra_container_spec,
                         extra_pod_config=extra_pod_spec)
scheduler = make_pod_spec(image='daskdev/dask:latest',
                          memory_limit='0.5G', memory_request='0.5G',
                          cpu_limit=0.5, cpu_request=0.5, threads_per_worker=1,
                          env={'EXTRA_PIP_PACKAGES': pip_packages},
                          extra_container_config=extra_container_spec,
                          extra_pod_config=extra_pod_spec
                          )

dask.config.set({"kubernetes.scheduler-service-type": "LoadBalancer"})

cluster = KubeCluster(scheduler_pod_template=scheduler, pod_template=pod_spec, n_workers=1,
                      deploy_mode="remote",
                      env={'EXTRA_PIP_PACKAGES': pip_packages}, port=8786, scheduler_service_wait_timeout=300)

cluster.adapt(minimum=1, maximum=3)
time.sleep(10)


with open(f"{scheduler_file_dir}/.scheduler", "w") as scheduler:
    scheduler.write(str(cluster.scheduler_address))

with open(f"{scheduler_file_dir}/.dashboard", "w") as dashboard:
    dashboard.write(str(cluster.dashboard_link))



while True:
    time.sleep(600)
