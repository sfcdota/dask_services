# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    boot.sh                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cbach <cbach@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/11 13:33:55 by cbach             #+#    #+#              #
#    Updated: 2021/01/29 15:15:29 by cbach            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

openrc default
service mariadb setup
cp mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
service mariadb start
touch /var/log/mysql.log
chown mysql:mysql /var/log/mysql.log
chmod 777 /var/log/mysql.log
mysql -u root -e "CREATE DATABASE wordpress; " && mysql wordpress < wordpress.sql
mysql -u root -e "CREATE USER IF NOT EXISTS 'cbach'@'%';\
	SET password FOR 'cbach'@'%' = password('pass');\
	GRANT ALL PRIVILEGES ON wordpress.* TO 'cbach'@'%' IDENTIFIED BY 'pass';\
	FLUSH PRIVILEGES;"
service mariadb stop

/usr/bin/mysqld_safe
status = $?
if [ $? -ne 0 ]; then
  echo "Failed to start mysql: $?"
  exit $?
fi

#mysql_install_db --user=root --basedir=/usr --datadir=/var/lib/mysql --pid-file=/run/mysqld/mysqld.pid --port=3306 --bind-address=0.0.0.0 --skip-networking=OFF #dp porta vse rabotalo
#sleep 3
#mysqld --user=root --basedir=/usr --datadir=/var/lib/mysql --pid-file=/run/mysqld/mysqld.pid --port=3306 --bind-address=0.0.0.0 --skip-networking=OFF &
# mysql -u root --skip-password -e "\
#  	 		CREATE DATABASE wordpress;\
#  	 		GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';\
# 			ALTER USER root@localhost IDENTIFIED VIA mysql_native_password USING PASSWORD('');
#  	 		FLUSH PRIVILEGES;"
 	 		# UPDATE mysql.user SET plugin='mysql_native_password' WHERE user='root';\
# use wordpress UPDATE mysql.user SET plugin='mysql_native_password' WHERE user='root';

# mysql -u root --execute="CREATE DATABASE wordpress;"
# mysql -u root wordpress < wordpress.sql
# mysql -u root --execute="CREATE USER 'cbach'@'%';"
# mysql -u root --execute="SET password FOR 'cbach'@'%' = password('password');"
# mysql -u root --execute="GRANT ALL PRIVILEGES ON wordpress.* TO 'cbach'@'%' IDENTIFIED BY 'password';"
# mysql -u root --execute="FLUSH PRIVILEGES;"
