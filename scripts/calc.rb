require 'rest_client'
require 'pp'

#pp RestClient.put('http://ip:9200/crawl/links/kkk','{ "content":["ab1","efxx","dd1f1rr2"]}')

#pp RestClient.get('http://ip:9200/crawl/links/kkk')


def calc(data)
  pp str = URI.encode("http://ip:9200/crawl/links/#{data['key1']}")
  begin
    array= JSON.parse(RestClient.get(str))["_source"]["content"]
    #  pp array
    arr = []
    arr1 = []
    data["content"].reverse.each do |i|
      if array && array.find_index(i)
        arr << i
      else
        arr1 << i
      end
    end

    pp RestClient.put(str,data.to_json)

    #array[data["key"]]=data["content"]
    #@@array
    arr1
  rescue
    puts "!!!!"*80

    #  pp data
    pp RestClient.put(str,data.to_json)
    data["content"]
  end
end


=begin
$array={}



def calc(data)

  pp $array[data["key"]]

  arr = []

  arr1 = []

  data["content"].each do |i|

    if $array[data["key"]] && $array[data["key"]].find_index(i)

      arr << i

    else

      arr1 << i

    end

  end



  $array[data["key"]]=data["content"]

  #@@array

  arr1

end



=end

