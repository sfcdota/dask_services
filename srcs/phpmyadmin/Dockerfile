# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cbach <cbach@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/11 13:34:17 by cbach             #+#    #+#              #
#    Updated: 2021/01/26 23:13:37 by cbach            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.12

LABEL maintainer = "cbach"

WORKDIR /dir/
COPY ./srcs/ .

RUN apk -U upgrade && apk add --no-cache nginx wget php7-fpm php7-common php7-iconv php7-json php7-gd php7-curl \
		php7-xml php7-mysqli php7-imap php7-cgi fcgi php7-pdo php7-pdo_mysql php7-soap php7-xmlrpc php7-posix \
		php7-mcrypt php7-gettext php7-ldap php7-ctype php7-dom php7-session php7-mbstring supervisor && \
		mkdir -p /run/nginx /var/www/html && mv localhost /etc/nginx/conf.d/default.conf && \
		mv supervisord.conf /etc/supervisord.conf && cd /var/www/html && \
		wget http://files.directadmin.com/services/all/phpMyAdmin/phpMyAdmin-5.0.2-all-languages.tar.gz && \
		tar zxf phpMyAdmin-5.0.2-all-languages.tar.gz && rm phpMyAdmin-5.0.2-all-languages.tar.gz && \
		mv phpMyAdmin-5.0.2-all-languages phpmyadmin && \
		cd /dir && mv config.inc.php /var/www/html/phpmyadmin/config.inc.php && \
		mv php-fpm.conf /etc/php7/


EXPOSE 5000

CMD ["/usr/bin/supervisord"]
