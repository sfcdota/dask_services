#
# Copyright (c) 2021 Maxim Gazizov All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

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

#delete old
minikube config set memory 6144
minikube delete

#start minikube VM
minikube start --cpus 4 --vm-driver=docker --disk-size=55G


if [ $? -ne 0 ]; then
  exit 1
fi

minikube update-context > /dev/null 2>&1
eval $(minikube docker-env)
minikube addons enable metallb

minikubeip=$(minikube ip)
freeipstart=$(echo $minikubeip | sed -e "s/\.[0-9]\+$/.1/")
tillminikube=$(echo $minikubeip | sed -e "s/\.[0-9]\+$//").$(($(echo $minikubeip | grep -Eo "[0-9]+$") - 1))
fromminikube=$(echo $minikubeip | sed -e "s/\.[0-9]\+$//").$(($(echo $minikubeip | grep -Eo "[0-9]+$") + 1))
freeipend=$(echo $minikubeip | sed -e "s/\.[0-9]\+$//").255
sed -i "s/- [0-9].*$/- "$freeipstart"-"$tillminikube"/g" $SRCS_DIR/metallb.yaml
sed -i "$ s/- [0-9].*$/- "$fromminikube"-"$freeipend"/g" $SRCS_DIR/metallb.yaml


echo "iprange is now set"
echo "set pasv_address to ftps config to support ftp join via terminal"
sed -i "s/pasv_address=.*$/pasv_address="$freeipstart"/g" $FTPS_DIR/srcs/vsftpd.conf
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$freeipstart":5050/g" $MYSQL_DIR/srcs/wordpress.sql
sed -i "s/imagePullPolicy: .*/imagePullPolicy: Never/g" $DEPLOYMENTS_DIR/*.yaml
sed -i "s/loadBalancerIP: .*/loadBalancerIP: $freeipstart/g" $SERVICES_DIR/*.yaml
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$freeipstart":5050/g" $WORDPRESS_DIR/srcs/wp-config.php

#set metallb config
kubectl apply -f $SRCS_DIR/metallb.yaml

docker-compose -f $SRCS_DIR/docker-compose.yml build --parallel


#configs
kubectl apply -f $SRCS_DIR/metallb.yaml
kubectl apply -f $DEPLOYMENTS_DIR
kubectl apply -f $SERVICES_DIR
kubectl apply -f $OTHERS_DIR
kubectl apply -f $OTHERS_DIR/datastorage/local.yaml
# kubectl patch pvc ftps-pv-claim -p '{"metadata":{"finalizers": []}}' --type=merge

sleep 8
minikube dashboard
