#
# Copyright (c) 2021 Maxim Gazizov All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

mkdir -p /root/csv-files/ && mkdir -p /root/csv-files/results/
echo "$username:$password" | chpasswd
usermod -d / root
addgroup $test_username
adduser $test_username -D -h /root/csv-files -G $test_username
adduser $my_username -D -h / -G root
echo "$my_username:$my_password" | chpasswd
echo "$test_username:$test_password" | chpasswd
chown $test_username:$test_username /root/csv-files
# sleep 10000000
# vsftpd
