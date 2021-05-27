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
OTHERS_DIR=others
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

sed -i "s/pasv_address=.*$/pasv_address="$1"/g" $FTPS_DIR/srcs/vsftpd.conf
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$1":5050/g" $MYSQL_DIR/srcs/wordpress.sql
sed -i "s/imagePullPolicy: .*/imagePullPolicy: Always/g" $DEPLOYMENTS_DIR/*.yaml
sed -i "s/loadBalancerIP: .*/loadBalancerIP: $1/g" $SERVICES_DIR/*.yaml
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$1":5050/g" $WORDPRESS_DIR/srcs/wp-config.php
echo "set pasv_address to ftps config to support ftp join via terminal"

kubectl delete -f $DEPLOYMENTS_DIR > /dev/null 2>&1
kubectl delete -f $SERVICES_DIR > /dev/null 2>&1
kubectl delete $(kubectl get pods -o name | grep dask) > /dev/null 2>&1
kubectl delete -f $OTHERS_DIR

# docker system prune -af

echo "applying configurations for services..."
kubectl apply -f $SERVICES_DIR

echo "building containers..."
docker-compose -f $SRCS_DIR/docker-compose.yml build --parallel


cd srcs
echo "pushing containers to dockerhub"
docker-compose push
cd ..

echo "applying configurations for deployments"
kubectl apply -f $DEPLOYMENTS_DIR
kubectl apply -f $OTHERS_DIR
