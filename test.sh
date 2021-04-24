kek=0
kubectl get svc | grep pending || kek=$?
while [ "${kek}" -ne 1 ]; do
	sleep 2
	kubectl get svc | grep pending || kek=$?
done
