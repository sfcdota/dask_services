eval $(minikube docker-env)
kubectl patch pvc ftps-pv-claim -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl delete -f .
kubectl delete $(kubectl get pods -o name | grep generator)
docker rm -f $(docker ps -f "name=generator" --format "{{.ID}}")
docker rmi -f generator
docker build -t generator .
kubectl apply -f .
sleep 5
kubectl exec -it $(kubectl get pods -o name | grep generator) -- bash
