freeipstart=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$/.1/")
echo "freeipstart = $freeipstart"
tillminikube=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//").$(($(echo $(minikube ip) | grep -Eo "[0-9]+$") - 1))
echo "tillminikube = $tillminikube"
fromminikube=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//").$(($(echo $(minikube ip) | grep -Eo "[0-9]+$") + 1))
echo "fromminikube = $fromminikube"
freeipend=$(echo $(minikube ip) | sed -e "s/\.[0-9]\+$//").254
echo "freeipend = $freeipend"
sed -i "s/- [0-9].*$/- "$freeipstart"-"$tillminikube"/g" srcs/metallb/metallb.yaml
sed -i "$ s/- [0-9].*$/- "$fromminikube"-"$freeipend"/g" srcs/metallb/metallb.yaml

echo "iprange is now set"
echo "set pasv_address to ftps config to support ftp join via terminal"
sed -i "s/pasv_address=.*$/pasv_address="$freeipstart"/g" srcs/ftps/configs/vsftpd.conf
sed -i "s/http:\/\/[0-9].*5050/http:\/\/"$freeipstart":5050/g" srcs/mysql/srcs/wordpress.sql
