require 'onstomp'

# A simple message producer
client = OnStomp.connect('stomp://admin:admin@ip:61613')
client.send('/queue//queue/gi_add', 'hello world====')
client.disconnect

