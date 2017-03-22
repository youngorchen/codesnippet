MAX=80
#TIME1=10

for ((i=0; i<$MAX+10; ++i))
do
  ehco; ruby fetch_builder.rb bb $TIME1 &
done


