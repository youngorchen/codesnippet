#echo "" > /data/scripts/wang/zhihuantong/log/development.log
#echo "" > /data/scripts/wang/zhihuantong/log/test.log
#echo "" > scripts/web/log/passenger.3333.log

find scripts -name "*.log"  | xargs -I {} -t sh -c "> {}"
find scripts -name "*.pdf"  | xargs -I {} -t sh -c "> {}"
find scripts -name "*.jpg"  | xargs -I {} -t sh -c "> {}"
find scripts -name "*.Rout"  | xargs -I {} -t sh -c "> {}"
find scripts -name "*.zip"  | xargs -I {} -t sh -c "> {}"

rm -rf /data/scripts/report/data/*

rm -rf  /data/scripts/wang/zhihuantong.tgz
gem list > scripts/gemlist.txt
tar -cf scripts_03.tar scripts back.sh
sz  scripts_03.tar

rm -rf scripts_03.tar

