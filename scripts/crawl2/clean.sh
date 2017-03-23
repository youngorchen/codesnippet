kill -9 $(ps -ef|grep -E 'crawl'|grep -v grep|awk '{print $2}' )
rm -rf ___*
