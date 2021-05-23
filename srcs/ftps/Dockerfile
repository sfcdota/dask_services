#
# Copyright (c) 2021 Maxim Gazizov All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM alpine:3.12
WORKDIR /dir/
COPY ./srcs/ .
EXPOSE 20 21 35000 35001 35002

RUN apk update && apk upgrade && apk add --no-cache vsftpd supervisor openssl shadow && \
	openssl req -x509 -nodes -newkey rsa:2048 \
	-keyout /etc/ssl/certs/ftps.key -out /etc/ssl/certs/ftps.pem \
	-subj "/C=RU/ST=Kazan/L=Kazan/O=KPFU/OU=sfcdota/CN=localhost" && \
	mkdir -p /root/csv-files/ && mkdir -p /root/csv-files/results/ && \
	mv supervisord.conf /etc/supervisord.conf && \
	cp vsftpd.conf /etc/vsftpd/vsftpd.conf && mv vsftpd.conf /etc/vsftpd.conf

CMD ["/usr/bin/supervisord"]
