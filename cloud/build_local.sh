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
#images
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
