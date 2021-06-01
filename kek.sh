OTHERS_DIR=others
DEPLOYMENTS_DIR=deployments
echo "applying configurations for deployments"
kubectl apply -f $DEPLOYMENTS_DIR
kubectl apply -f $OTHERS_DIR
kubectl apply -f $OTHERS_DIR/datastorage/cloud.yaml
