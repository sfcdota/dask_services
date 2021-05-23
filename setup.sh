#
# Copyright (c) 2021 Maxim Gazizov All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

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

#delete old
minikube delete

#start minikube VM
minikube start --memory 10240 --cpus 4 --vm-driver=virtualbox --disk-size=55G


if [ $? -ne 0 ]; then
  exit 1
fi

minikube update-context
eval $(minikube docker-env)
minikube addons enable metallb

freeipstart=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$/.2/")
tillminikube=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//").$(($(echo $(minikube ip) | grep -Eo "[0-9]+$") - 1))
fromminikube=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//").$(($(echo $(minikube ip) | grep -Eo "[0-9]+$") + 1))
freeipend=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//").254
sed -i "s/- [0-9].*$/- "$freeipstart"-"$tillminikube"/g" $SRCS_DIR/metallb.yaml
sed -i "$ s/- [0-9].*$/- "$fromminikube"-"$freeipend"/g" $SRCS_DIR/metallb.yaml


echo "iprange is now set"
echo "set pasv_address to ftps config to support ftp join via terminal"
sed -i "s/pasv_address=.*$/pasv_address="$freeipstart"/g" $SRCS_DIR/ftps/configs/vsftpd.conf
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$freeipstart":5050/g" $SRCS_DIR/mysql/srcs/wordpress.sql

#set metallb config
kubectl apply -f $SRCS_DIR/metallb.yaml

docker-compose -f $SRCS_DIR/docker-compose.yml build --parallel


#configs
kubectl apply -f $SRCS_DIR/metallb.yaml
kubectl apply -f $DEPLOYMENTS_DIR
kubectl apply -f $SERVICES_DIR

# kubectl patch pvc ftps-pv-claim -p '{"metadata":{"finalizers": []}}' --type=merge

sleep 8
minikube dashboard &
