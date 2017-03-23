kill -9 $(ps -ef|grep -E 'pingtime'|grep -v grep|awk '{print $2}' )

