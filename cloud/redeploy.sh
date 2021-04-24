kubectl delete -f deployments
kubectl delete -f services
kubectl delete $(kubectl get svc -o name | grep dask-root)
kubectl delete $(kubectl get pods -o name | grep dask-root)

kubectl apply -f services
kubectl apply -f deployments
