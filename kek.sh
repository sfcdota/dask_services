SRCS_DIR=srcs
DASK_DIR=srcs
DEPLOYMENTS_DIR=deployments
SERVICES_DIR=services
OTHERS_DIR=others
NGINX_DIR=$SRCS_DIR/nginx
FTPS_DIR=$SRCS_DIR/ftps
GRAFANA_DIR=$SRCS_DIR/grafana
INFLUXDB_DIR=$SRCS_DIR/influxdb
MYSQL_DIR=$SRCS_DIR/mysql
PHPMYADMIN_DIR=$SRCS_DIR/phpmyadmin
WORDPRESS_DIR=$SRCS_DIR/wordpress
DASK_SERVER_DIR=$DASK_DIR/server
DASK_CLIENT_DIR=$DASK_DIR/client
GENERATOR_DIR=$DASK_DIR/generator/
DOCKER_USER=sfcdota


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
