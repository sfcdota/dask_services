#
# Copyright (c) 2021 Maxim Gazizov All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

mkdir -p /root/csv-files/ && mkdir -p /root/csv-files/results/
echo "$FTPS_USERNAME:$FTPS_PASSWORD" | chpasswd
usermod -d / root
addgroup $FTPS_TEST_USERNAME
adduser $FTPS_TEST_USERNAME -D -h /root/csv-files -G $FTPS_TEST_USERNAME
adduser $FTPS_MY_USERNAME -D -h / -G root
echo "$FTPS_MY_USERNAME:$FTPS_MY_PASSWORD" | chpasswd
echo "$FTPS_TEST_USERNAME:$FTPS_TEST_PASSWORD" | chpasswd
chown $FTPS_TEST_USERNAME:$FTPS_TEST_USERNAME /root/csv-files
# sleep 10000000
# vsftpd
