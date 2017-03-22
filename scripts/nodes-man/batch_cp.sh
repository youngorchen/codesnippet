sshpass -p "v," ssh root@172.16.0.85 ls
sshpass -p "v," scp mfsclient root@172.16.0.85:/etc/init.d/


# cd /etc/init.d
# chmod +x mfsclient
# chkconfig ----add mfsclient
# chkconfig --level 35 mfsclient on
