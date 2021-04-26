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


def receiveSignal(sigNum, frame=None):
    cluster.close()
    os.remove(cluster.scheduler_address)
    exit(0)


signal.signal(signal.SIGINT, receiveSignal)
signal.signal(signal.SIGQUIT, receiveSignal)
signal.signal(signal.SIGTERM, receiveSignal)

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
                         memory_limit='7Gi', memory_request='200Mi',
                         cpu_limit=1, cpu_request=0.1,
                         env={'EXTRA_PIP_PACKAGES': pip_packages},
                         extra_container_config=extra_container_spec,
                         extra_pod_config=extra_pod_spec)
scheduler = make_pod_spec(image='daskdev/dask:latest',
                          memory_limit='8Gi', memory_request='500Mi',
                          cpu_limit=1, cpu_request=0.1,
                          env={'EXTRA_PIP_PACKAGES': pip_packages},
                          extra_container_config=extra_container_spec,
                          extra_pod_config=extra_pod_spec
                          )

cluster = KubeCluster(scheduler_pod_template=pod_spec, pod_template=scheduler, n_workers=1,
                      deploy_mode="remote",
                      env={'EXTRA_PIP_PACKAGES': pip_packages}, scheduler_service_wait_timeout=300,
                      name="dask")


cluster.adapt(minimum=1, maximum=5)
time.sleep(10)


with open(f"{scheduler_file_dir}/.scheduler", "w") as scheduler:
    scheduler.write(str(cluster.scheduler_address))

with open(f"{scheduler_file_dir}/.dashboard", "w") as dashboard:
    dashboard.write(str(cluster.dashboard_link))

cluster.shutdown_on_close = True

while True:
    time.sleep(600)
