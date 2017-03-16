#passenger stop --port 3333
PORT=4567

netstat -ltpn | grep $PORT

ps -ef | grep "tcp://0.0.0.0:$PORT" | grep -v grep |awk '{print $2}' | xargs kill -9

netstat -ltpn | grep $PORT
