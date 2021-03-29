docker rm -f $(docker ps -aq)
docker build -t phpmyadmin .
sleep 2
kubectl rollout restart deployment phpmyadmin
sleep 5
kubectl exec -it $(kubectl get pods -o name | grep phpmyadmin) -- sh
