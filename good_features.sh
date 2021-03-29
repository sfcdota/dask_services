eval $(minikube docker-env)
eval $(minikube -p minikube docker-env)
ssh-keygen -f "/home/sfcdota/.ssh/known_hosts" -R "192.168.99.126"
ssh root@192.168.99.126 #pass root
rewrite /phpmyadmin/(.*) /$1  break;

curl -Ik https://192.168.99.126/wordpress
kubectl cp [pod name]:[file location in pod] [dir] #for copy file from pod to local
kubectl cp grafana-deployment-d4f77759-dp5wc:/dir/grafana/data/grafana.db grafana.db #example
docker rm -f $(docker ps -a -q) && docker build -t nginx srcs/nginx/ && kubectl rollout restart deployment

kubectl exec -it $(kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')     -- pkill nginx
kubectl exec -it $(kubectl get pods -o name | grep ftps) -- pkill
#ftps check connection
nc -zv 172.17.0.2 21
ftp 172.17.0.2
docker build -t ftps . && docker run -dit -p 21:21 -p 22800-23000:22800-23000 --name=ftps ftps


lastoctet=$(echo $(minikube ip) | grep -Eo "[0-9]+$")
lastoctet=$(($lastoctet + 1))
echo $(echo $(minikube ip) | sed "s/[0-9]\{3,\}$/"$lastoctet"228/g")


kubectl get svc | grep ftps | grep -Eo $(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//")".[0-9]+"


export IP=$(minikube ip)
cub=$(echo $IP | grep -Eo "[0-9]+$")
IP=$(echo $IP | sed -e "s/\.[0-9]\+$//")
nmap -sP -PR $IP.$cub | grep "Host is up"
while [ "$?" != 1 ]
do
    cub=$(($cub + 1))
    nmap -sP -PR $IP.$cub > /dev/null 2>&1
done
IP="$IP.$cub"


sudo docker inspect -f "{{ .NetworkSettings.IPAddress }}" nginx
