if [ $1 == 1 ]; then
	echo "check passed"
fi


SRCS_DIR=srcs
eval $(minikube docker-env)
docker build -t $1 $SRCS_DIR/$1
kubectl delete $(kubectl get pod -o name | grep "$1")
sleep 10
kubectl exec -it $(kubectl get pods -o name | grep "$1") -- bash
kubectl exec -it $(kubectl get pods -o name | grep "$1") -- sh
