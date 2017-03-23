#passenger start --daemonize --port 3333 --min-instances 6 --max-pool-size 10 --log-file /home/log/diff.log > /dev/null 2>&1
puma -e production -p 7777 -t 20:40 -w 20 -d
