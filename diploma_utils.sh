kubectl delete $(kubectl get pods -o name | grep dask)
# minikube start --memory 12288 --cpus 4 --vm-driver=virtualbox --disk-size 60G
# minikube start --memory 8192 --cpus 5 --vm-driver=virtualbox --disk-size 60G

