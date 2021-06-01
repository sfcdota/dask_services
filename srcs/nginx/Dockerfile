FROM alpine:3.12
WORKDIR /dir/
COPY ./srcs .

RUN apk update && apk upgrade && apk add --no-cache  nginx openssl && \
	mkdir -p /run/nginx && \
	mv localhost /etc/nginx/conf.d/default.conf && \
	openssl req -x509 -nodes -newkey rsa:2048 \
	-keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.pem \
	-subj "/C=RU/ST=Kazan/L=Kazan/O=KPFU/OU=sfcdota/CN=localhost"


EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
