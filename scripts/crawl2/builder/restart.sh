#passenger stop --port 3333
PORT=7777

netstat -ltpn | grep $PORT

#netstat -ltpn | grep $PORT | cut -d / -f 1 | cut -d N -f 2| xargs kill -s SIGUSR2
ps -ef | grep "tcp://0.0.0.0:$PORT" | grep -v grep |awk '{print $2}' | xargs kill -s SIGUSR2

netstat -ltpn | grep $PORT
