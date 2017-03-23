# -*- coding: UTF-8 -*-

require 'open-uri'
require 'nokogiri'
require 'pp'
require 'json'
require 'yaml'  
require 'cgi'

def post_proc(obj)
	#puts 'XXXXX'
	#dump obj
	if obj.class != Hash
		#puts obj.class
		#puts "exit.."
		return
	end

	obj.each do |k,v|
		obj.delete(k) if k =~ /^_/

		if v.class == Array
			v.each do |i|
				post_proc(i)
			end
		end 
	end
	#obj
end

def handle_error
	exp = $@.join("\n")
	err = "error:#{$!} at:#{exp}"
	puts err

	dump "EXCEPTION!!!",$root_file
	File.open("#{$root_file}.error", "a+") { |file|  file << err}
	
#	puts "+++++++++++++++++++++++++++"
end

def pause
	$stdin.gets
end

def debug(*item)
	dump item
	puts "========="*80
end

def debug_exit(*item)
	dump item
	puts "========="*80
	exit(0)
end

def dump(*item)
	#item.each do |i|
	#	puts ""
	#end
	puts "-"*80
	pp item
end

#http to file name
def fn_convt(url)
	CGI.escape(url.gsub(/\//,'_').gsub(/:|\./,'_').scan(/http(.*)/)[0][0])
end


def get_web_file(url,cfg)
#pp "XXX"*80
#pp url
	url=CGI.unescape(url).strip
#pp url

	#fn = url.gsub(/\//,'_').gsub(/:|\./,'_').scan(/http(.*)/)[0][0]
	fn = fn_convt(url)
	fn = fn.gsub(/\?/,'_')  #bug here!
	#puts fn

	#curl -x 116.53.8.105:2386 --max-time 5 --retry 10 --retry-delay 1 -C - -o a.html http://www.baidu.com

	# --max-time 5 --retry 10 --retry-delay 1
	#str = 'curl  -L '
	str = 'curl -L -s '

	if cfg['proxy']  #proxy
		if cfg['proxy'] =~ /ARGV/
			proxy = eval cfg['proxy']
		else
			proxy = cfg['proxy']
		end
		str += " -x #{proxy} " if proxy.strip.length > 10 
	end

	str += " --max-time #{cfg['max-time']} " if cfg['max-time']  #max-time
	str += " --retry #{cfg['retry']} " if cfg['retry']  #retry
	str += " --retry-delay #{cfg['retry-delay']} " if cfg['retry-delay']  #retry-delay
	str += " -C - " if cfg['duan-dian'] == 'true'
	str += " -o #{fn} \"#{url}\"" 
#puts "-----"*80
#	puts str
	puts `#{str}`

	puts code = $?
	raise '11' if $?.exitstatus != 0  #timeout, change proxy?
		
   	fn
end

def get_batch_files(urls,cfg)
	# --max-time 5 --retry 10 --retry-delay 1
	str = 'curl -L '
	str = 'curl ' if $debug

	if cfg['proxy']  #proxy
		if cfg['proxy'] =~ /ARGV/
			proxy = eval cfg['proxy']
		else
			proxy = cfg['proxy']
		end
		str += " -x #{proxy} " if proxy.strip.length > 10 
	end
	
	str += " --max-time #{cfg['max-time']} " if cfg['max-time']  #max-time
	str += " --retry #{cfg['retry']} " if cfg['retry']  #retry
	str += " --retry-delay #{cfg['retry-delay']} " if cfg['retry-delay']  #retry-delay
	str += " -C - " if cfg['duan-dian'] == 'true'
	
	urls.each {  |url|  str += " -O #{url}" } 
	
	puts str
	puts `#{str}`

	puts code = $?
	raise '11' if $?.exitstatus != 0  #timeout, change proxy?
end

def proc_website(cfg)
	puts "processing web pages.."

	url = cfg["url"]
	min_file_size = cfg["min_file_size"].to_i
	min_file_size = 1000 if min_file_size == 0

	puts min_file_size

	url = eval(url) if url =~ /ARGV/

	fn = nil

	if url =~ /http/
		fn = get_web_file(url,cfg)

	else #local file
		#puts "this is local file"
		fn = url
	end
	
	dump fn
#pp  fn
#puts "-+-."*80
	begin
		#file is not exist?
		 unless File.exist?(fn)
#	puts "exist"*80
			raise '12'
		end

		begin
			a=open(fn,"r:#{cfg['encode']}").read
#pp a
		rescue
#	puts "eee"*80
			raise '15' #read error!
		end
		#check "</html>"
		unless a =~ /<\/html>/m
#	puts "html"*80
			raise '13'
		end
		
		#check file size
		unless a.length > min_file_size
#	puts "size"*80
			raise '14'
		end
		
	end
#puts "parse..."*80
	$root_file = "#{fn}"

	doc = Nokogiri::HTML(a)
end

def proc_yaml(b,obj)
	pp b
	arr = []

	b.split(/ /).each do |item|
		if item =~ /(@(\w+))/  
			pp item
			pp $1
			item = item.gsub($1,'"'+$root_cfg['website']["#{$2}"]+'"')
			pp item #+ '1'

			if item =~ /("ARGV.*?")\.*/
				puts "replace ARGV"
				#pp $1
				#pp item
				#pp $1.strip
				#pp eval($1.strip)
				item = item.gsub($1,eval($1))
			end
			#exit
			
			pp item #+ '2'
			item = eval(item)
			pp item #+ '3'
			item = '"' + item + '"'
			#exit
		end

		if item =~ /^\$(\w+)/ 
			pp item
			pp $1
			#pp obj
			#pp obj[$1]
			#exit
			item = '"' + obj[$1] + '"'
			pp item
			#exit
		end

		arr << item
	end
	b = arr.join(" ")
	pp b
	#exit
	str = `#{b}`

end

def proc_field(k,v,doc,obj)
	puts "========> processing [#{k}] [#{v}] =======>"
	#pp doc
	n = 0
	css = nil
	pat = nil
	pat_n = 0
	jot = nil
	eval_str = nil
	att = nil
	yml_ret = nil

	unless v
		dump "%%%%%%%%%%%%%%%%%%%%%%%%%%5no value with #{k}"
		obj[k] = ''
		return 
	end

	v.each do |a,b|
		#pp a,b
		case a
		when /^from$/
			css = b
		when /^from\[(.*?)\]/
			#puts "from_n pattern!!!"
			n = $1.to_i
			css = b
		when /^pattern$/
			pat = b
		when /^pattern\[(.*?)\]/
			pat_n = $1.to_i
			pat = b
		when /^join$/
			jot = b
		when /^attr$/
			att = b
		when /^exp$/
			#dump b
			#puts "????"
			if b.index("obj['_") #已经替换了！
				eval_str = b
			else
				vars = b.scan(/\w+/).flatten
				dump vars
				
				vars.each do |var|
					b.gsub!(/#{var}/,"obj[\'#{var}\']") if var =~ /^_/
				end
				eval_str = b
				pp eval_str
			end
			#dump b
		when /^exec$/
			yml_ret = proc_yaml(b,obj)
		else
			#
		end
	end

	dump n,css,pat,jot,eval_str,att
	begin
		if css
			#if css == 'img'  
			#	t = doc.search(css)[0].attr('src') unless att
			if att
				t = doc.search(css)[n].attr(att) 
			else
				t = doc.search(css)[n].content.strip
			end
		
			if pat
				pp t,pat
				t = t.scan /#{pat}/m
				t = t.flatten[0]
				
				if jot
					t = t.join(jot)
				end
				pp t
			end
			obj[k] = t				
		elsif eval_str

			tmp = eval eval_str
			dump tmp

			if pat
				pp tmp,pat
				tmp = tmp.scan /#{pat}/m
				pp tmp
				if jot
					tmp = tmp.join(jot)
				end
				pp tmp
			end
			obj[k] = tmp	
			#pause
		elsif yml_ret 
			tmp = yml_ret
			pp tmp,pat
			if pat
				tmp = tmp.scan /#{pat}/m
				tmp = tmp.flatten[0]
			end
			begin
				puts "JSON builder.."
				tmp = JSON.parse(tmp)[k]
				pp tmp
				obj[k] = tmp
				#exit
			rescue
				obj[k] = tmp
			end
		else	

		end
	rescue
		handle_error
		obj[k] = ''
	end
	#doc.search(v['from'])[n]
	#n = v['item']? 0 : v['item'].to_i
	#pp obj
	#obj
end

def proc_array(k,v,doc,obj)
	#proc_field(k,v,doc,obj)
	puts "array.."
	name = k.split('[')[0]
	pp name
	arr = []
	obj[name] = arr
	dump obj

	css = v['from']
	v.delete('from')

	doc.search(css).each do |t|
		#pp t
		tmp = {}
		v.each do |v1,v2|
		  begin
			dump v1,tmp,v2
			puts "*******************************************"
			proc_field(v1,v2,t,tmp)
			dump v1,tmp,v2
			puts "*******************************************"
		  rescue
		    handle_error
		    next
		  end	
		end
		#dump tmp
		arr << tmp
		#pause
		#$stdin.gets
	end
end

def proc_object(obj_name,cfg,doc)
	#pp cfg
	obj = {}
	cfg.each do |k,v|
	  	begin	
			if not k.index("[")
				proc_field(k,v,doc,obj)
			else
				proc_array(k,v,doc,obj)
			end
		rescue
			handle_error
			next
	  	end
	end
	puts ".............RESULTRESULT"

	obj = post_proc obj

	if $root_cfg['website']['output'] == 'file'
		#$stdout = File.open($root_file+".json4", "w")

		#$stdout.puts obj.to_json
		
		#$stdout.flush
		#$stdout.close

		# 取回输出方法的默认输出对象。
		#$stdout = STDOUT
		File.open($root_file+".json4", "w") do |f|
			f.puts obj.to_json
		end		
	else
		puts obj.to_json
	end

	obj
end

def main
	yaml_file = ARGV[0] || "detail_cfg.yaml"
        pp yaml_file
	cfg = YAML.load(File.open(yaml_file))  

	pp cfg

	$root_cfg = cfg
	$root_file = nil

	puts "---"
	doc = nil

	begin
		cfg.each do |k,v|
			if k == 'website'
				doc = proc_website(v) 
			else
				proc_object(k,v,doc)
			end
		end
	#rescue 
	#	handle_error
	end
end

# yaml_file url proxy_ip
def run_main
	begin
		main
		return 0
	rescue Exception => e
		puts $@
		dump e.to_s.to_i
		return e.to_s.to_i+1000
	end
end

if __FILE__ == $0
	pp ARGV
	ret = run_main
end

#{$root_file}.error {$root_file}.json4

