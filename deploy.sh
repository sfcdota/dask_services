#
# Copyright (c) 2021 Maxim Gazizov All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

if [ $1 == 1 ]; then
	echo "check passed"
fi

ip=$1

#set DIR variables
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

echo "set pasv_address to ftps config to support ftp join via terminal"
sed -i "s/pasv_address=.*$/pasv_address="$ip"/g" $SRCS_DIR/ftps/configs/vsftpd.conf
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$ip":5050/g" $SRCS_DIR/mysql/srcs/wordpress.sql
sed -i "s/loadBalancerIP: .*/loadBalancerIP: $ip/g" $SERVICES_DIR/*.yaml
sed -i "s/externalIPs: .*/externalIPs: $ip/g" $SERVICES_DIR/*.yaml


kubectl delete -f $DEPLOYMENTS_DIR
kubectl delete -f $SERVICES_DIR
kubectl delete $(kubectl get pods -o name | grep dask)
# docker system prune -af


kubectl apply -f $SERVICES_DIR

docker-compose -f $SRCS_DIR/docker-compose.yml build --parallel


cd srcs
docker-compose push
cd ..


kubectl apply -f $DEPLOYMENTS_DIR

