require 'socket'

s = TCPSocket.new 'localhost', 2000
IO.copy_stream(STDIN, s)

s.close
