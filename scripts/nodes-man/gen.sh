NUM="$1"

RES=`ifcfg eth$NUM up 2>&1 | grep "Cannot find"`

if [ "$RES" != "" ];then
    echo "not found!"
else
    echo "found!"
fi
