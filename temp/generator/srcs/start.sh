
# sleep 1000000000
if [ $auto -ne 0 ];
then
	python main.py;
else
	sleep 1000000000000000;
fi

while [ $? -ne 0 ]; do
  sleep 20
done
