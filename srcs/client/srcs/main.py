#
# Copyright (c) 2021 Maxim Gazizov All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

from dask.distributed import Client
import dask.dataframe as dd
from pathlib import Path
import os
import datetime
import time



def get_current_time():
    return datetime.datetime.fromtimestamp(time.time())


def check_for_new_files(queue):
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
                print(f"New file {_} is found, but it is not fully copied or damaged. \
                    Wait for next iteration...")
                continue
            if "custom" not in _ and ".csv" in _ or ".xz" in _ or ".zip" in _ or ".gzip" in _ or ".bz2" in _:
                csv_is_found = True
                if _ not in queue:
                    queue.add(_)
                    count += 1
        print(f"{get_current_time()}checking new csv files... Now queue = {queue if queue else None}. \
            New {count} files. Remain {len(queue)} files")
        time.sleep(10.0)



def calculation(file_path, results_path, client, filename):
    result = None
    file_name_part = filename[:-4]
    result_dir = f"{results_path}/{file_name_part}-result"
    df = dd.DataFrame
    try:
        print(f"{get_current_time()}\tTrying to execute {file_path}")
        df = dd.read_csv(f"{file_path}", blocksize="64MB", error_bad_lines=False, names=fieldnames)
        df["Mark"] = dd.to_numeric(df["Mark"], errors='coerce')
    except BaseException as e:
        print(f"{get_current_time()}\tError on read_csv func. CSV file might be damaged. Error description : {e}")
        # print(f"******************SCHEDULER LOGS******************\n\n\n")
        # for _ in client.get_scheduler_logs(5):
        #     print(f"_{os.linesep}")
        # print(f"******************WORKER LOGS******************\n\n\n")
        # for _ in client.get_worker_logs(5):
        #     print(f"_{os.linesep}")
        return 1
    try:
        df = df.groupby(["Name", "Subject"]).mean()
        Path(result_dir).mkdir(parents=True, exist_ok=True)
        result = client.compute(df, sync=True)
    except BaseException as e:
        print(f"{get_current_time()}\tError on computation. Check the source code. Error description: {e}")
        client.cancel([result, df], force=True)
        client.restart()
        return 1
    for _ in compression_types:
        if f"to_{_}" == file_name_part[-len(_) - 3:] or _ == "csv":
            result.to_csv(f"{result_dir}/result.{_}", mode='w', encoding='utf-8')
    print(f"{file_path} execution successful. Result = {result}")
    return 0


def execute(ftps_path, results_path, client):
    queue = set()
    while True:
        check_for_new_files(queue)
        if queue:
            file_to_handle = queue.pop()
        else:
            time.sleep(3.0)
            continue
        file_path = f"{ftps_path}/{file_to_handle}"
        if calculation(file_path, results_path, client, file_to_handle) == 0:
            os.remove(file_path)
        else:
            return 1
        time.sleep(3.0)


def get_scheduler_address():
    while True:
        try:
            print(f"Trying to find .scheduler file in{cluster_dir}...")
            files = os.listdir(cluster_dir)
            print(f"Found files: {files}")
            for _ in files:
                print(f"{cluster_dir}/{_}")
                if _ == ".scheduler":
                    print("trying to read .scheduler file")
                    with open(f"{cluster_dir}/{_}", "r") as scheduler:
                        address = scheduler.readline()
                        print(f"Scheduler address = {address}")
                        return address
        except OSError:
            print("scheduler file not found")
        time.sleep(10.0)


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


ftps_dir, csv_dir, system_dir, results_dir, cluster_dir = init_directories()
fieldnames = ["Name", "Subject", "Mark", "Date"]
compression_types = ['zip', 'bz2', 'gzip', 'xz', 'csv']

print("PROCESS STARTED. TRYING TO CONNECT SCHEDULER")
client = None
while True:
    try:
        client = Client(get_scheduler_address())
        client.get_versions(check=True)
        if execute(csv_dir, results_dir, client) == 0:
            time.sleep(3.0)
        else:
            time.sleep(20)
    except OSError:
        print("Scheduler is not ready. Time out to connect. Be sure it's not shut downed.")
        time.sleep(10.0)

