eval $(minikube docker-env)
kubectl delete -f ftps.yaml
kubectl delete $(kubectl get pods -o name | grep ftps)
docker rm -f $(docker ps -f "name=ftps" --format "{{.ID}}")
docker rmi -f ftps
docker build -t ftps .
kubectl apply -f ftps.yaml
# docker run -dit -p 3000:3000 --name=grafana grafana
sleep 5
# docker exec -it $(docker ps -f "name=grafana" --format "{{.ID}}") sh
kubectl exec -it $(kubectl get pods -o name | grep ftps) -- sh
