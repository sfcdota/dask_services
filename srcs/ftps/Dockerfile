# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cbach <cbach@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/11 13:33:43 by cbach             #+#    #+#              #
#    Updated: 2021/04/27 19:45:21 by cbach            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.12

LABEL maintainer = "cbach"


WORKDIR /dir/
COPY ./srcs/ .
EXPOSE 20 21 35000 35001 35002

RUN apk update && apk upgrade && apk add --no-cache vsftpd supervisor openssl shadow && \
	openssl req -x509 -nodes -newkey rsa:2048 \
	-keyout /etc/ssl/certs/ftps.key -out /etc/ssl/certs/ftps.pem \
	-subj "/C=RU/ST=Kazan/L=Kazan/O=21School/OU=cbach/CN=localhost"
RUN mkdir -p /root/csv-files/ && mkdir -p /root/csv-files/results/ && \
	mv supervisord.conf /etc/supervisord.conf && \
	cp vsftpd.conf /etc/vsftpd/vsftpd.conf && mv vsftpd.conf /etc/vsftpd.conf

CMD ["/usr/bin/supervisord"]