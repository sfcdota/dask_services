docker rm -f mysql
docker build -t mysql .
docker run -dit --name=mysql -p 3306:3306  mysql
sleep 5
docker exec -it mysql sh
