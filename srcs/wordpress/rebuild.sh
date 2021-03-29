eval $(minikube docker-env)
kubectl delete -f wordpress.yaml
kubectl delete $(kubectl get pods -o name | grep wordpress)
docker rm -f $(docker ps -f "name=wordpress" --format "{{.ID}}")
docker rmi -f wordpress
docker build -t wordpress .
kubectl apply -f wordpress.yaml
sleep 2
kubectl exec -it $(kubectl get pods -o name | grep wordpress) -- sh
