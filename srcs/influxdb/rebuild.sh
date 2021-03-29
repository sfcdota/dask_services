eval $(minikube docker-env)
kubectl delete -f influxdb.yaml
kubectl delete $(kubectl get pods -o name | grep influxdb)
docker rm -f $(docker ps -f "name=influxdb" --format "{{.ID}}")
docker rmi -f influxdb
docker build -t influxdb .
kubectl apply -f influxdb.yaml
# docker run -dit -p 8086:8086 --name=influxdb influxdb
sleep 5
# docker exec -it $(docker ps -f "name=influxdb" --format "{{.ID}}") sh
kubectl exec -it $(kubectl get pods -o name | grep influxdb) -- sh
