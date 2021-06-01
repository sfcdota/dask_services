gcloud container clusters resize cluster-2 --num-nodes=0 --zone=europe-central2-b


kubectl delete pods --field-selector status.phase=Failed
sudo swapoff -a


eval $(minikube docker-env)
ssh-keygen -f "/home/sfcdota/.ssh/known_hosts" -R "34.116.235.52"
ssh root@34.116.235.52 #pass root
rewrite /phpmyadmin/(.*) /$1  break;

curl -Ik https://192.168.99.126/wordpress
kubectl cp [pod name]:/[file location in pod] [file] #for copy file from pod to local

kubectl exec -it $(kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}') -- pkill nginx

#ftps check connection
nc -zv 172.17.0.2 21
ftp 34.116.235.52 -> pass -> dir -> ls

sudo docker inspect -f "{{ .NetworkSettings.IPAddress }}" nginx



cat sshclient.py | ssh root@34.116.235.52 python
