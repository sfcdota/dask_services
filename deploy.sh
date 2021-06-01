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

if [ $(gcloud container clusters list --filter="name=dask" --format="value(name)" | grep dask || echo "empty") == "dask" ]; then
	echo "Cluster with name dask already exists. Skip cluster creation step."; else
	gcloud container clusters create dask --disk-size=50GB --disk-type=pd-ssd --image-type=UBUNTU --machine-type=e2-standard-8 --zone=europe-central2-b --num-nodes 1 \
	--no-enable-cloud-logging --no-enable-cloud-monitoring --no-enable-stackdriver-kubernetes --release-channel=stable --no-shielded-integrity-monitoring
fi

if [ $(gcloud container node-pools list --cluster=dask --filter="name=dask" --format="value(name)" | grep dask || echo "empty") == "dask" ]; then
	echo "Node pool with name dask already exists in cluster dask. Skip node-pool creation step."; else
	gcloud container node-pools create dask --cluster=dask --disk-size=50GB --disk-type=pd-ssd --image-type=UBUNTU --machine-type=e2-highmem-8 --zone=europe-central2-b --num-nodes=2 \
	--no-enable-autoscaling  --no-shielded-integrity-monitoring
fi

if [ $(gcloud filestore instances list --format="name=dask" --format="value(name)" | grep dask || echo "empty") == "dask" ]; then
	echo "Filestore with name dask already exists. Skip filestore creation step."; else
	gcloud filestore instances create dask --zone=europe-central2-b --file-share=capacity=1TB,name=dask_storage --network=name=default
fi

if [ $(gcloud compute addresses list --format="name=clusterlb" --format="value(name)" | grep clusterlb || echo "empty") == "clusterlb" ]; then
	echo "Static external ip with name clusterlb already reserved. Skip external ip creation step."; else
	gcloud compute addresses create clusterlb --region=europe-central2
fi

gcloud container clusters get-credentials dask
ip_nfs=$(gcloud filestore instances list --format="value(networks.ipAddresses[0])")

ip=$(gcloud compute addresses list --format="value(address)")

echo "Static external ip reserved with address $ip"
sed -i "s/pasv_address=.*$/pasv_address="$ip"/g" $FTPS_DIR/srcs/vsftpd.conf
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$ip":5050/g" $MYSQL_DIR/srcs/wordpress.sql
sed -i "s/imagePullPolicy:.*/imagePullPolicy: Always/g" $DEPLOYMENTS_DIR/*.yaml
sed -i "s/loadBalancerIP:.*/loadBalancerIP: $ip/g" $SERVICES_DIR/*.yaml
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$ip":5050/g" $WORDPRESS_DIR/srcs/wp-config.php
sed -i "s/server:.*/server: $ip_nfs/g" $OTHERS_DIR/datastorage/cloud.yaml

echo "Configs have set."
kubectl delete -f $OTHERS_DIR > /dev/null 2>&1
kubectl delete -f $DEPLOYMENTS_DIR > /dev/null 2>&1
kubectl delete -f $SERVICES_DIR > /dev/null 2>&1
kubectl delete $(kubectl get pods -o name | grep dask) > /dev/null 2>&1

echo "applying configurations for services..."
kubectl apply -f $SERVICES_DIR

echo "building containers..."
docker-compose -f $SRCS_DIR/docker-compose.yml build --parallel

if [ $? == 1 ]; then
	echo "Docker socket is not running. Exit." && exit
fi

cd srcs
echo "pushing containers to dockerhub"
docker-compose push
cd ..

echo "applying configurations for deployments"
kubectl apply -f $DEPLOYMENTS_DIR
kubectl apply -f $OTHERS_DIR
kubectl apply -f $OTHERS_DIR/datastorage/cloud.yaml
