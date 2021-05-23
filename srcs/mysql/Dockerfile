FROM alpine:3.12
WORKDIR /dir/
COPY ./srcs/ .
VOLUME /sys/fs/cgroup
VOLUME /var/lib/mysql

RUN apk update && apk upgrade && apk add --no-cache mysql mysql-client openrc supervisor && \
	mkdir -p /run/mysqld && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && chmod 777 /var/run/mysqld

EXPOSE 3306

CMD sh boot.sh
