#
# Copyright (c) 2021 Maxim Gazizov All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

openrc default
service mariadb setup
cp mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
service mariadb start
touch /var/log/mysql.log
chown mysql:mysql /var/log/mysql.log
chmod 777 /var/log/mysql.log
mysql -u root -e "CREATE DATABASE wordpress; " && mysql wordpress < wordpress.sql
mysql -u root -e "CREATE USER IF NOT EXISTS 'sfcdota'@'%';\
	SET password FOR 'sfcdota'@'%' = password('pass');\
	GRANT ALL PRIVILEGES ON wordpress.* TO 'sfcdota'@'%' IDENTIFIED BY 'pass';\
	FLUSH PRIVILEGES;"
service mariadb stop
/usr/bin/mysqld_safe
