find ./___* -size -5k | xargs rm  
find ./___* -mtime +3 | xargs rm 

cd builder

find . -name "*ip*"  -mtime +3 | xargs rm 
#find . -name "*ip*"  -size -5k | xargs rm 

find . -name "*5*"  -mtime +3 | xargs rm
#find . -name "*5*"  -size -5k | xargs rm

find . -name "*g*"  -mtime +3 | xargs rm
#find . -name "*g*"  -size -5k | xargs rm

find . -name "___*" -mtime +3 | xargs rm
#find . -name "___*" -size -5k | xargs rm


