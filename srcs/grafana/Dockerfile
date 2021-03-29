# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cbach <cbach@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/11 13:33:32 by cbach             #+#    #+#              #
#    Updated: 2021/01/28 21:44:10 by cbach            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.12

LABEL maintainer = "cbach"
WORKDIR /dir/

COPY ./srcs/ .
ADD https://dl.grafana.com/oss/release/grafana-7.3.7.linux-amd64-musl.tar.gz /dir
RUN apk -U upgrade && \
	tar zxf grafana-7.3.7.linux-amd64-musl.tar.gz && rm grafana-7.3.7.linux-amd64-musl.tar.gz && \
	mv grafana-7.3.7 grafana && mv defaults.ini grafana/conf/ && mv sample.ini grafana/conf/ && mkdir -p grafana/data/ && \
	mv grafana.db /dir/grafana/data/grafana.db

WORKDIR /dir/grafana/bin/
EXPOSE 3000

CMD ["./grafana-server"]

