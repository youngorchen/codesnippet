# -*- coding: UTF-8 -*-

require 'open-uri'
require 'nokogiri'
require 'pp'
require 'json'
require 'yaml'  

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
	puts "error:#{$!} at:#{$@}"
	dump "EXCEPTION!!!",$root_file
	`echo > #{$root_file}.error`
	puts "genertating .... #{$root_file}.error ++++++++++++++++++++++++++++++++"

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
	exit
end

def dump(*item)
	#item.each do |i|
	#	puts ""
	#end
	puts "-"*80
	pp item
end

def get_web_file(url,cfg)
	fn = url.gsub(/\//,'_').gsub(/:|\./,'_').gsub(/\?/,'_').scan(/http(.*)/)[0][0]
	#puts fn

	#curl -x 116.53.8.105:2386 --max-time 5 --retry 10 --retry-delay 1 -C - -o a.html http://www.baidu.com

	# --max-time 5 --retry 10 --retry-delay 1
	str = 'curl  '

	str += " -x #{cfg['proxy']} " if cfg['proxy']  #proxy
	str += " --max-time #{cfg['max-time']} " if cfg['max-time']  #max-time
	str += " --retry #{cfg['retry']} " if cfg['retry']  #retry
	str += " --retry-delay #{cfg['retry-delay']} " if cfg['retry-delay']  #retry-delay
	str += " -C - " if cfg['duan-dian'] == 'true'
	str += " -o #{fn} #{url}" 
	puts str
	puts `#{str}`

   	fn
end

def get_batch_files(urls,cfg)
	# --max-time 5 --retry 10 --retry-delay 1
	str = 'curl -s '
	str = 'curl ' if $debug

	str += " -x #{cfg['proxy']} " if cfg['proxy']  #proxy
	str += " --max-time #{cfg['max-time']} " if cfg['max-time']  #max-time
	str += " --retry #{cfg['retry']} " if cfg['retry']  #retry
	str += " --retry-delay #{cfg['retry-delay']} " if cfg['retry-delay']  #retry-delay
	str += " -C - " if cfg['duan-dian'] == 'true'
	
	urls.each {  |url|  str += " -O #{url}" } 
	
	puts str
	puts `#{str}`
end

def proc_website(cfg)
	puts "processing web pages.."
	url = cfg["url"]

	url = eval(url) if url =~ /ARGV/

	fn = nil

	if url =~ /http/
		fn = get_web_file(url,cfg)

	else #local file
		#puts "this is local file"
		fn = url
	end
	
	dump fn
	a=open(fn,"r:#{cfg['encode']}").read

	$root_file = "#{fn}"

	doc = Nokogiri::HTML(a)
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
					b.gsub!(/#{var}/,"obj[\'#{var}\']")
				end
				eval_str = b
			end
			#dump b
		else
			#
		end
	end

	dump n,css,pat,jot,eval_str,att
	begin
		if css
			#if css == 'img'  
			#	t = doc.css(css)[0].attr('src') unless att
			if att
				t = doc.css(css)[n].attr(att) 
			else
				t = doc.css(css)[n].content.strip
			end
		
			if pat
				pp t,pat
				t = t.scan /#{pat}/
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
				tmp = tmp.scan /#{pat}/
				pp tmp
				if jot
					tmp = tmp.join(jot)
				end
				pp tmp
			end
			obj[k] = tmp	
			#pause
		else

		end
	rescue
		handle_error
		obj[k] = ''
	end
	#doc.css(v['from'])[n]
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

	doc.css(css).each do |t|
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
		$stdout = File.open($root_file+".json4", "w")

		$stdout.puts obj.to_json
		
		$stdout.flush
		$stdout.close

		# 取回输出方法的默认输出对象。
		$stdout = STDOUT
	else
		puts obj.to_json
	end

	obj
end

yaml_file = ARGV[0] || "detail_cfg.yaml"
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
rescue 
	handle_error
end

