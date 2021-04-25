pip install dask_kubernetes
apt-get install vim -y
# sleep 100000
python main.py

while [ $? == 0 ]; do
  sleep 60
done
