kill -9 $(ps -ef|grep -E 'fetch_wrapper_test.rb'|grep -v grep|awk '{print $2}' )
