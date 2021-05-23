FROM alpine:3.12
COPY ./srcs .
VOLUME /root/
VOLUME /sys/fs/cgroup

RUN apk update && apk upgrade && apk add --no-cache influxdb supervisor && \
	tar xf telegraf.tar.gz && cp -R telegraf-1.17.1/* / && rm -rf telegraf.tar.gz telegraf-1.17.1 && \
	telegraf -sample-config --input-filter docker --output-filter influxdb > telegraf.conf && \
	mv supervisord.conf /etc/supervisord.conf

EXPOSE 8086

CMD ["/usr/bin/supervisord"]

# ADD	https://dl.influxdata.com/telegraf/releases/telegraf-1.17.1_static_linux_amd64.tar.gz /

