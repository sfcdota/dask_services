# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cbach <cbach@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/11 13:33:48 by cbach             #+#    #+#              #
#    Updated: 2021/01/29 13:24:30 by cbach            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.12

LABEL maintainer = "cbach"

COPY ./srcs .
VOLUME /root/
VOLUME /sys/fs/cgroup
ADD	https://dl.influxdata.com/telegraf/releases/telegraf-1.17.1_static_linux_amd64.tar.gz /
RUN apk update && apk upgrade && apk add --no-cache influxdb supervisor && \
	tar xf /telegraf-1.17.1_static_linux_amd64.tar.gz && cp -R telegraf-1.17.1/* / && rm -rf telegraf-1.17.1_static_linux_amd64.tar.gz telegraf-1.17.1 && \
	telegraf -sample-config --input-filter docker --output-filter influxdb > telegraf.conf && mv supervisord.conf /etc/supervisord.conf

EXPOSE 8086

CMD ["/usr/bin/supervisord"]
