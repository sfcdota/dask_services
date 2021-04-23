# # **************************************************************************** #
# #                                                                              #
# #                                                         :::      ::::::::    #
# #    setup.sh                                           :+:      :+:    :+:    #
# #                                                     +:+ +:+         +:+      #
# #    By: cbach <cbach@student.42.fr>                +#+  +:+       +#+         #
# #                                                 +#+#+#+#+#+   +#+            #
# #    Created: 2020/12/11 13:34:32 by cbach             #+#    #+#              #
# #    Updated: 2021/04/12 17:07:33 by cbach            ###   ########.fr        #
# #                                                                              #
# # **************************************************************************** #

#set DIR variables
NGINX_DIR=srcs/nginx
FTPS_DIR=srcs/ftps
GRAFANA_DIR=srcs/grafana
INFLUXDB_DIR=srcs/influxdb
METALLB_DIR=srcs/metallb
MYSQL_DIR=srcs/mysql
PHPMYADMIN_DIR=srcs/phpmyadmin
WORDPRESS_DIR=srcs/wordpress
DASK_SERVER_DIR=dask/server
DASK_CLIENT_DIR=dask/client
GENERATOR_DIR=dask/generator/

#delete old
minikube delete
#start minikube VM
minikube start --memory 10240 --cpus 4 --vm-driver=virtualbox --disk-size=55G
	# --extra-config=apiserver.authorization-mode=RBAC


if [ $? -ne 0 ]; then
  exit 1
fi

minikube update-context
# minikube start --memory 12288 --cpus 4 --nodes 2 --vm-driver=virtualbox
kubectl label nodes minikube type=main
# kubectl label nodes minikube-m02 type=dask
# kubectl get nodes --show-labels -o wide
eval $(minikube docker-env)
minikube addons enable metallb

#getting first available ip in minikube subnet
# lastoctet=$(echo $(minikube ip) | grep -Eo "[0-9]+$")
# lastoctet=$(($lastoctet + 1))
# freeipstart=$(echo $(minikube ip) | sed "s/[0-9]\{3,\}$/"0"/g")
# freeipend=$(echo $(minikube ip) | sed "s/[0-9]\{3,\}$/"255"/g")
# freeipstart=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//").$(($(echo $(minikube ip) | grep -Eo "[0-9]+$") + 1))
# freeipend=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//").254


freeipstart=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$/.2/")
tillminikube=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//").$(($(echo $(minikube ip) | grep -Eo "[0-9]+$") - 1))
fromminikube=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//").$(($(echo $(minikube ip) | grep -Eo "[0-9]+$") + 1))
freeipend=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//").254
sed -i "s/- [0-9].*$/- "$freeipstart"-"$tillminikube"/g" srcs/metallb/metallb.yaml
sed -i "$ s/- [0-9].*$/- "$fromminikube"-"$freeipend"/g" srcs/metallb/metallb.yaml

# echo "minikube ip = $(minikube ip)\\nFirst free ip in minikube subnet = $freeipstart"
# echo "changing metallb config to working properly with random minikube ip..."
# sed -i "s/- [0-9].*$/- "$freeipstart"-"$freeipend"/g" srcs/metallb/metallb.yaml
echo "iprange is now set"
echo "set pasv_address to ftps config to support ftp join via terminal"
sed -i "s/pasv_address=.*$/pasv_address="$freeipstart"/g" srcs/ftps/configs/vsftpd.conf
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$freeipstart":5050/g" srcs/mysql/srcs/wordpress.sql

#set metallb config
kubectl apply -f srcs/metallb/metallb.yaml

#images
docker build --no-cache -t nginx $NGINX_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t nginx $NGINX_DIR
  sleep 2
done
docker build --no-cache -t phpmyadmin $PHPMYADMIN_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t phpmyadmin $PHPMYADMIN_DIR
  sleep 2
done
docker build --no-cache -t ftps $FTPS_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t ftps $FTPS_DIR
  sleep 2
done
docker build --no-cache -t mysql $MYSQL_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t mysql $MYSQL_DIR
  sleep 2
done
docker build --no-cache -t wordpress $WORDPRESS_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t wordpress $WORDPRESS_DIR
  sleep 2
done

docker build --no-cache -t grafana $GRAFANA_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t grafana $GRAFANA_DIR
  sleep 2
done

docker build --no-cache -t influxdb $INFLUXDB_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t influxdb $INFLUXDB_DIR
  sleep 2
done

docker build --no-cache -t server $DASK_SERVER_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t server $DASK_SERVER_DIR
  sleep 2
done

docker build --no-cache -t client $DASK_CLIENT_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t client $DASK_CLIENT_DIR
  sleep 2
done


docker build --no-cache -t generator $GENERATOR_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t generator $GENERATOR_DIR
  sleep 2
done


#configs
kubectl apply -f srcs/secrets.yaml
kubectl apply -f $NGINX_DIR/nginx.yaml
kubectl apply -f $PHPMYADMIN_DIR/phpmyadmin.yaml
kubectl apply -f $FTPS_DIR/ftps.yaml
kubectl apply -f $MYSQL_DIR/mysql.yaml
kubectl apply -f $WORDPRESS_DIR/wordpress.yaml
kubectl apply -f $GRAFANA_DIR/grafana.yaml
kubectl apply -f $INFLUXDB_DIR/influxdb.yaml

kubectl apply -f $DASK_SERVER_DIR/rbac.yaml
kubectl apply -f $DASK_SERVER_DIR/server.yaml


kubectl apply -f $DASK_CLIENT_DIR/client.yaml

kubectl apply -f $GENERATOR_DIR/generator.yaml

kubectl patch pvc ftps-pv-claim -p '{"metadata":{"finalizers": []}}' --type=merge

sleep 8
minikube dashboard &
