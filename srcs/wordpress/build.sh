docker build -t wordpress .
docker run -dit --name=wordpress -p 5500:5500  wordpress
sleep 5
docker exec -it wordpress sh
