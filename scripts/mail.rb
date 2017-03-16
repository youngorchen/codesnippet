require 'net/smtp'
require 'rubygems'
require 'mailfactory'
require 'pp'

def sendmail(to, subject, text, *file)
	file = file.flatten
	pp file
	mail = MailFactory.new
	mail.from="service@cyhz.com"
	mail.subject=subject
	mail.text=text
        file.each {|f| mail.attach(f.to_s) }
	#mail.attach(file)
	mail.to = to

	#参数含义为：'your.smtp.server', 25, 'mail.from.domain','Your Account', 'Your Password', AuthType
	#AuthType: 1):plain 2):login 3):cram_md5

        smtp = Net::SMTP.start('smtp.exmail.qq.com',25,'qq.com','username','pwd',:login)    do |smtp|
	  smtp.send_mail(mail.to_s(), "mailbox@xx.com", to)
	end
end

if (ARGV.length < 4)
	puts "You should use like this: sendFile.rb 'to_addr' 'subject' 'text' 'filepath'"
else
	if File.file?ARGV[3]
		#pp ARGV[3..-1]
		sendmail(ARGV[0], ARGV[1], ARGV[2], ARGV[3..-1].flatten)
		puts "sendmail to #{ARGV[0]}, #{ARGV[1]}, #{ARGV[2]}, #{ARGV[3..-1]}";
	else
		puts "file not exist:" + ARGV[3]
	end

end

