# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cbach <cbach@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/11 13:33:43 by cbach             #+#    #+#              #
#    Updated: 2021/04/24 04:02:06 by cbach            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.12

LABEL maintainer = "cbach"


WORKDIR /dir/
COPY ./configs/ .
VOLUME /root
RUN apk update && apk upgrade && apk add --no-cache vsftpd supervisor openssl shadow && mv supervisord.conf /etc/supervisord.conf && \
	openssl req -x509 -nodes -newkey rsa:2048 \
	-keyout /etc/ssl/certs/ftps.key -out /etc/ssl/certs/ftps.pem \
	-subj "/C=RU/ST=Kazan/L=Kazan/O=21School/OU=cbach/CN=localhost" && \
	cp vsftpd.conf /etc/vsftpd/vsftpd.conf && mv vsftpd.conf /etc/vsftpd.conf && \
	mkdir /root/csv-files

EXPOSE 21 37000-37006

CMD ["/usr/bin/supervisord"]
