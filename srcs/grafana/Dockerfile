FROM alpine:3.12
WORKDIR /dir/
COPY ./srcs/ .

RUN apk -U upgrade && \
	tar zxf grafana.tar.gz && rm grafana.tar.gz && \
	mv grafana-7.3.7 grafana && mv defaults.ini grafana/conf/ && \
	mv sample.ini grafana/conf/ && mkdir -p grafana/data/ && \
	mv grafana.db /dir/grafana/data/grafana.db

WORKDIR /dir/grafana/bin/
EXPOSE 3000

CMD ["./grafana-server"]

# ADD https://dl.grafana.com/oss/release/grafana-7.3.7.linux-amd64-musl.tar.gz /dir
