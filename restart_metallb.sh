kubectl delete -f srcs/metallb/metallb.yaml
minikube addons disable metallb
sh change_configs.sh
sh redeploy.sh
minikube addons enable metallb
kubectl apply -f srcs/metallb/metallb.yaml
