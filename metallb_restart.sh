kubectl -n metallb-system delete cm config
kubectl apply -f srcs/metallb.yaml
kubectl -n metallb-system delete pod --all
kubectl -n metallb-system get pods -w
