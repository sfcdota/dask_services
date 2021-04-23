eval $(minikube docker-env)
kubectl delete -f .
kubectl delete $(kubectl get pods -o name | grep dask-server)
docker rm -f $(docker ps -f "name=dask-server" --format "{{.ID}}")
docker rmi -f dask-server
docker build -t dask-server .
kubectl apply -f .
# docker run -dit -p 3000:3000 --name=grafana grafana
sleep 5
# docker exec -it $(docker ps -f "name=grafana" --format "{{.ID}}") sh
kubectl exec -it $(kubectl get pods -o name | grep dask-server) -- bash
