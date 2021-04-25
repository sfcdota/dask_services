kubectl delete $(kubectl get pods -o name | grep dask)
