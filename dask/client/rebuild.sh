eval $(minikube docker-env)
kubectl delete -f client.yaml
kubectl delete $(kubectl get pods -o name | grep client)
docker rm -f $(docker ps -f "name=client" --format "{{.ID}}")
docker rmi -f client
docker build -t client .
kubectl apply -f client.yaml
sleep 5
kubectl exec -it $(kubectl get pods -o name | grep client) -- bash
