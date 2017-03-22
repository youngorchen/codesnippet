find ./http* -size -5k | xargs rm 
find ./http* -mtime +3 | xargs rm 


