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
DOCKER_USER=sfcdota


if [ $1 == 1 ]; then
	kubectl patch pvc ftps-pv-claim -p '{"metadata":{"finalizers": []}}' --type=merge
	kubectl delete -f cloud/deployments
	kubectl delete -f cloud/services
	kubectl delete $(kubectl get svc -o name | grep dask-root)
	kubectl delete $(kubectl get pods -o name | grep dask-root)
	kubectl patch pvc ftps-pv-claim -p '{"metadata":{"finalizers": []}}' --type=merge
	if [ $2 == 1 ]; then
		docker system prune -af
	fi
fi

kubectl apply -f cloud/services
kek=0
kubectl get svc | grep ftps | grep pending

while [ "${kek}" -ne 1 ]; do
	sleep 2
	kubectl get svc | grep ftps | grep pending
	kek=$?
	echo ""
done
sleep 2
ip=$(kubectl get svc ftps -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

echo "set pasv_address to ftps config to support ftp join via terminal"
sed -i "s/pasv_address=.*$/pasv_address="$ip"/g" srcs/ftps/configs/vsftpd.conf
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$ip":5050/g" srcs/mysql/srcs/wordpress.sql
sed -i "s/loadBalancerIP: .*/loadBalancerIP: $ip/g" dask/server/srcs/kubernetes.yaml


docker build --no-cache -t $DOCKER_USER/nginx $NGINX_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t $DOCKER_USER/nginx $NGINX_DIR
  sleep 2
done
docker build --no-cache -t $DOCKER_USER/phpmyadmin $PHPMYADMIN_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t $DOCKER_USER/phpmyadmin $PHPMYADMIN_DIR
  sleep 2
done
docker build --no-cache -t $DOCKER_USER/ftps $FTPS_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t $DOCKER_USER/ftps $FTPS_DIR
  sleep 2
done
docker build --no-cache -t $DOCKER_USER/mysql $MYSQL_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t $DOCKER_USER/mysql $MYSQL_DIR
  sleep 2
done
docker build --no-cache -t $DOCKER_USER/wordpress $WORDPRESS_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t $DOCKER_USER/wordpress $WORDPRESS_DIR
  sleep 2
done

docker build --no-cache -t $DOCKER_USER/grafana $GRAFANA_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t $DOCKER_USER/grafana $GRAFANA_DIR
  sleep 2
done

docker build --no-cache -t $DOCKER_USER/influxdb $INFLUXDB_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t $DOCKER_USER/influxdb $INFLUXDB_DIR
  sleep 2
done

docker build --no-cache -t $DOCKER_USER/server $DASK_SERVER_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t $DOCKER_USER/server $DASK_SERVER_DIR
  sleep 2
done

docker build --no-cache -t $DOCKER_USER/client $DASK_CLIENT_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t $DOCKER_USER/client $DASK_CLIENT_DIR
  sleep 2
done


docker build --no-cache -t $DOCKER_USER/generator $GENERATOR_DIR
while [ $? -ne 0 ]; do
  docker build --no-cache -t $DOCKER_USER/generator $GENERATOR_DIR
  sleep 2
done

docker push $DOCKER_USER/nginx
docker push $DOCKER_USER/phpmyadmin
docker push $DOCKER_USER/ftps
docker push $DOCKER_USER/mysql
docker push $DOCKER_USER/wordpress
docker push $DOCKER_USER/grafana
docker push $DOCKER_USER/influxdb
docker push $DOCKER_USER/server
docker push $DOCKER_USER/client
docker push $DOCKER_USER/generator


kubectl apply -f cloud/deployments

