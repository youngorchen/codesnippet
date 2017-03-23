ruby 273_crawl.rb
find . -size 0 | xargs rm -rf {}
tar cvf all.zip *.json
sz all.zip
