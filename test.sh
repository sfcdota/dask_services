SRCS_DIR=srcs
DASK_DIR=srcs
DEPLOYMENTS_DIR=deployments
SERVICES_DIR=services
NGINX_DIR=$SRCS_DIR/nginx
FTPS_DIR=$SRCS_DIR/ftps
GRAFANA_DIR=$SRCS_DIR/grafana
INFLUXDB_DIR=$SRCS_DIR/influxdb
METALLB_DIR=$SRCS_DIR/metallb
MYSQL_DIR=$SRCS_DIR/mysql
PHPMYADMIN_DIR=$SRCS_DIR/phpmyadmin
WORDPRESS_DIR=$SRCS_DIR/wordpress
DASK_SERVER_DIR=$DASK_DIR/server
DASK_CLIENT_DIR=$DASK_DIR/client
GENERATOR_DIR=$DASK_DIR/generator/
DOCKER_USER=sfcdota


freeipstart=172.16.0.1


echo "iprange is now set"
echo "set pasv_address to ftps config to support ftp join via terminal"
sed -i "s/pasv_address=.*$/pasv_address="$freeipstart"/g" $SRCS_DIR/ftps/srcs/vsftpd.conf
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$freeipstart":5050/g" $SRCS_DIR/mysql/srcs/wordpress.sql
sed -i "s/loadBalancerIP: .*/loadBalancerIP: $freeipstart/g" $SERVICES_DIR/*.yaml
sed -i "s/externalIPs: .*/externalIPs: $freeipstart/g" $SERVICES_DIR/*.yaml

