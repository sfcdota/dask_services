mkdir -p /root/csv-files/ && mkdir -p /root/csv-files/results/
echo "$FTPS_USERNAME:$FTPS_PASSWORD" | chpasswd
usermod -d / root
usermod -d /root/csv-files ftp
chown ftp:ftp /root/csv-files
adduser $FTPS_TEST_USERNAME -D -h /root/csv-files -G ftp
adduser $FTPS_MY_USERNAME -D -h / -G root
echo "$FTPS_MY_USERNAME:$FTPS_MY_PASSWORD" | chpasswd
echo "$FTPS_TEST_USERNAME:$FTPS_TEST_PASSWORD" | chpasswd

# sleep 10000000
# vsftpd