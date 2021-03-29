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
echo $IP
