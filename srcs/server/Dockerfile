FROM daskdev/dask:latest
WORKDIR /dir/
RUN apt-get update -y && apt-get upgrade -y && \
	pip install git+https://github.com/dask/distributed@main && \
	pip install git+https://github.com/dask/dask@main && \
	pip install git+https://github.com/sfcdota/dask-kubernetes@main

ENV "FTPS_DIR"="/ftps-files"
ENV "CSV_DIR"="/ftps-files/csv-files"
ENV "SYSTEM_DIR"="/ftps-files/.system"
ENV "RESULTS_DIR"="/ftps-files/csv-files/results"
ENV "SCHEDULER_FILE_DIR"="/ftps-files/.system/.cluster"

EXPOSE 30000
COPY ./srcs/ .

ENTRYPOINT ["python", "main.py"]
