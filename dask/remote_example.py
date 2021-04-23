import dask.distributed
import pandas as pd
from dask.distributed import Client
import dask.dataframe as dd
from pathlib import Path
import os
import datetime
import time
import pandas
client = Client("192.168.99.3:8786")

# def inc(x):
#         return x + 1


# x = client.submit(inc, 10)
# s=client.gather(x)
# print(str(s))


# df = dd.read_csv("ftp://192.168.99.2:21/root/csv-files/Nf.csv", storage_options={
#                                                                  "username": "root",
#                                                                  "password": "cbach"})
# client.scatter(df)
# result = client.compute(df.groupby(["Name"]).mean(), sync=True)
# print(result)

# pdf = pd.DataFrame(pandas.read_csv("marks.csv", chunksize=6400000))
# print(pdf)
# df = dd.from_pandas(pdf)
# result = client.compute(df.groupby(["Name"]).mean(), sync=True)
#
# print(result)

csv_dir = "/dir/ftps-files/csv-files"

# df = dd.read_csv(f"{csv_dir}/Nf.csv", blocksize="64MB")
df = dd.read_csv("marks.csv", blocksize="64MB")
result = client.compute(df.groupby(["Name"]).mean(), sync=True)
print(result)
