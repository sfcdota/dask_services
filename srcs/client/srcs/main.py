import dask.distributed
from dask.distributed import Client
import dask.dataframe as dd
from pathlib import Path
import os
import datetime
import time

def get_current_time():
    return datetime.datetime.fromtimestamp(time.time())


def write_log(msg, fd, time=True):
    timestamp = ""
    if time:
        timestamp = get_current_time()
    print(f"{timestamp}\t{msg}")
    fd.write(f"{timestamp}\t{msg}{os.linesep}")


def check_for_new_files(log, queue):
    count = 0
    csv_is_found = False
    while not csv_is_found:
        files = os.listdir(csv_dir)
        for _ in files:
            file_path = f"{csv_dir}/{_}"
            if os.path.isdir(file_path):
                continue
            try:
                os.rename(file_path, file_path)
            except OSError:
                write_log(f"New file {_} is found, but it is not fully copied or damaged. \
                    Wait for next iteration...", log)
                continue
            if ".csv" in _ and "custom" not in _:
                csv_is_found = True
                if _ not in queue:
                    queue.add(_)
                    count += 1
        write_log(f"checking new csv files... Now queue = {queue if queue else None}. \
            New {count} files. Remain {len(queue)} files", log)
        time.sleep(3.0)



def calculation(file_path, log, results_path, client, filename):
    df = None
    result = None
    try:
        write_log(f"Trying to execute {file_path}", log)
        df = dd.read_csv(f"{file_path}", blocksize="64MB")
    except BaseException as e:
        write_log(f"Error on read_csv func. CSV file might be damaged. Error description : {e}", log)
        write_log(f"Deleting errored csv files...", log)
        write_log(f"******************SCHEDULER LOGS******************\n\n\n", log)
        for _ in client.get_scheduler_logs(10):
            write_log(f"_{os.linesep}", log, False)
        write_log(f"******************WORKER LOGS******************\n\n\n", log)
        for _ in client.get_worker_logs(10):
            write_log(f"_{os.linesep}", log, False)
        return 1
    try:
        df = df.groupby(["Name", "Subject"]).mean()
        Path(f"{results_path}/{filename[:-4]}-result").mkdir(parents=True, exist_ok=True)
        df.visualize(f"{results_path}/{filename}/visualized")
        result = client.compute(df, sync=True)
    except BaseException as e:
        write_log(f"Error on computation. Check the source code. Error description: {e}", log)
        return 1
    result.to_csv(f"{results_path}/{filename}/result.txt", mode='w', encoding='utf-8')
    # with open(f"{results_path}/{filename}/result.txt", "w") as file:
    #     file.write(f"{result}{os.linesep}")
    write_log(f"{file_path} execution successful. Result = {result}", log)
    return 0


def execute(log, ftps_path, results_path, client):
    queue = set()
    while True:
        check_for_new_files(log, queue)
        if queue:
            file_to_handle = queue.pop()
        else:
            time.sleep(3.0)
            continue
        file_path = f"{ftps_path}/{file_to_handle}"
        if calculation(file_path, log, results_path, client, file_to_handle) == 0:
            os.remove(file_path)
        else:
            return 1
        time.sleep(3.0)


def get_scheduler_address(log):
    while True:
        try:
            write_log(f"Trying to find .scheduler file in{cluster_dir}...", log)
            files = os.listdir(cluster_dir)
            write_log(f"Found files: {files}", log)
            for _ in files:
                print(f"{cluster_dir}/{_}")
                if _ == ".scheduler":
                    write_log("trying to read .scheduler file", log)
                    with open(f"{cluster_dir}/{_}", "r") as scheduler:
                        address = scheduler.readline()
                        write_log(f"Scheduler address = {address}", log)
                        return address
        except OSError:
            write_log("scheduler file not found", log)
        time.sleep(3.0)


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
    Path(f"{system}/.logs").mkdir(parents=True, exist_ok=True)
    return ftps, csv, system, results, scheduler_file


ftps_dir, csv_dir, system_dir, results_dir, cluster_dir = init_directories()


with open(f"{system_dir}/.logs/{get_current_time()}", "w") as log:
    write_log("Log created.", log)
    while True:
        try:
            client = Client(get_scheduler_address(log))
            with open(f"{cluster_dir}/.dashboard", "r") as dashboard:
                address = dashboard.readline()
                write_log(f"dashboard address = {address}", log)
        except OSError:
            write_log("Scheduler is not ready. Time out to connect. Be sure it's not shut downed.", log)
            time.sleep(3.0)
            continue
        client.get_versions(check=True)
        if execute(log, csv_dir, results_dir, client) == 0:
            time.sleep(3.0)
        else:
            time.sleep(60)
