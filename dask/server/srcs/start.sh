
# sleep 1000000000
python main.py

while [ $? -e 0 ]; do
  sleep 60
done
