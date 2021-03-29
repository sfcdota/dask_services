eval $(minikube docker-env)
kubectl delete -f mysql.yaml
kubectl delete $(kubectl get pods -o name | grep mysql)
docker rm -f $(docker ps -f "name=mysql" --format "{{.ID}}")
docker rmi -f mysql
docker build -t mysql .
kubectl apply -f mysql.yaml
sleep 2
kubectl exec -it $(kubectl get pods -o name | grep mysql) -- sh
