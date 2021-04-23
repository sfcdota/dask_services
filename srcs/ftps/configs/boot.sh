echo "$FTPS_USERNAME:$FTPS_PASSWORD" | chpasswd
adduser -h /root/csv-files "test"
echo "$FTPS_TEST_USERNAME:$FTPS_TEST_PASSWORD" | chpasswd
