# kubectl delete $(kubectl get pods -o name | grep dask-root)

kubectl delete pods --field-selector status.phase=Failed

# minikube start --memory 12288 --cpus 4 --vm-driver=virtualbox --disk-size 60G
# minikube start --memory 8192 --cpus 5 --vm-driver=virtualbox --disk-size 60G

# kubectl auth can-i list pods --as=system:serviceaccout:default:dask-svc
sudo swapoff -a
