FROM daskdev/dask:2021.4.1

LABEL maintainer = "cbach"

WORKDIR /dir/
EXPOSE 22

ENV "FTPS_DIR"="/ftps-files"
ENV "CSV_DIR"="/ftps-files/csv-files"
ENV "SYSTEM_DIR"="/ftps-files/.system"
ENV "RESULTS_DIR"="/ftps-files/csv-files/results"
ENV "SCHEDULER_FILE_DIR"="/ftps-files/.system/.cluster"
RUN apt-get update -y && apt-get upgrade -y && \
    pip install 'git+https://github.com/sfcdota/dask-kubernetes@main' dask==2021.04.1 \
    distributed==2021.04.1 jupyter-server-proxy
COPY ./srcs/ .
RUN apt-get install -y openssh-server procps supervisor && \
	mkdir -p /var/run/sshd /var/log/supervisor && \
	mv sshd_config /etc/ssh/sshd_config && \
	mv supervisord.conf /etc/supervisord.conf && \
	ssh-keygen -A


CMD ["/usr/bin/supervisord"]
