eval $(minikube docker-env)
kubectl delete -f grafana.yaml
kubectl delete $(kubectl get pods -o name | grep grafana)
docker rm -f $(docker ps -f "name=grafana" --format "{{.ID}}")
docker rmi -f grafana
docker build -t grafana .
kubectl apply -f grafana.yaml
# docker run -dit -p 3000:3000 --name=grafana grafana
sleep 5
# docker exec -it $(docker ps -f "name=grafana" --format "{{.ID}}") sh
kubectl exec -it $(kubectl get pods -o name | grep grafana) -- sh
