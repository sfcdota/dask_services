echo "$FTPS_USERNAME:$FTPS_PASSWORD" | chpasswd
useradd $FTPS_TEST_USERNAME -d /root/csv-files -s /bin/false -m
echo "$FTPS_TEST_USERNAME:$FTPS_TEST_PASSWORD" | chpasswd