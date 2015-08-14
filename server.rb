require 'socket'

Socket.tcp_server_loop(2000) do |client|
  while line = client.gets
    puts line
  end
  client.close
end
