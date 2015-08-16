require 'socket'
require './helpers.rb'

s = TCPSocket.new 'localhost', 2000
STDIN.each_line do |l|
  if l == "\n" then break end
  s.puts l
end
s.close
