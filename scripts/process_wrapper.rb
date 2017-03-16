require 'pp'

cmd = "ruby -e sleep 1000; puts 'hello'"


def keep_running(cmd,n)
  (1..n.to_i).each do |t|
    system( "while [[ 1 ]]; do " + cmd + "; done &")
  end
end

pp ARGV

exit if ARGV.length < 2

keep_running(ARGV[0],ARGV[1])



