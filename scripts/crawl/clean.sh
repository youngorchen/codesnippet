kill -9 $(ps -ef|grep -E 'fetch_builder'|grep -v grep|awk '{print $2}' )
#killall ruby
killall curl
#rm -rf http*

find ./http*  | xargs rm 
rm -rf /mnt/mfs/analyseHtml/error/* 
