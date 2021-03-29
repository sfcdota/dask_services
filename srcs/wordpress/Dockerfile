# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cbach <cbach@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/11 13:34:27 by cbach             #+#    #+#              #
#    Updated: 2021/01/29 15:06:58 by cbach            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.12

LABEL maintainer = "cbach"

WORKDIR /dir/

COPY ./srcs/ .
RUN apk update && apk upgrade && apk add --no-cache wget nginx php7 php7-common php7-iconv php7-json php7-gd php7-curl php7-xml \
	php7-mysqli php7-imap php7-cgi fcgi php7-pdo php7-pdo_mysql php7-soap php7-xmlrpc php7-posix php7-mcrypt php7-gettext \
	php7-ldap php7-ctype php7-dom php7-fpm php7-opcache php7-zlib supervisor && mkdir -p /run/nginx /var/www/html && \
	mv localhost /etc/nginx/conf.d/default.conf && mv supervisord.conf /etc/supervisord.conf && \
	sed -i 's/daemonize = yes/daemonize = no/g' /etc/php7/php-fpm.conf
RUN wget http://wordpress.org/latest.tar.gz && tar zxf latest.tar.gz && rm latest.tar.gz && \
	cp -r wordpress/* /var/www/html && mv wp-config.php /var/www/html

EXPOSE 5050

CMD ["/usr/bin/supervisord"]
