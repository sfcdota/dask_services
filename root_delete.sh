kubectl delete $(kubectl get svc -o name | grep dask-root)
kubectl delete $(kubectl get pods -o name | grep dask-root)