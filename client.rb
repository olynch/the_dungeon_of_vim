require 'socket'

s = TCPSocket.new 'localhost', 2000

puts s.gets
s.puts ""
sleep 1

s.close
