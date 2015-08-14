require 'socket'
Clients=[]

Thread.new do
  Socket.tcp_server_loop(2000) do |c|
    Clients << c
    Clients.delete(c) if c.gets.chomp == ""
  end
end

loop do
  Clients.each do |c|
    #Clients.delete(c) if IO.select([c], nil, nil, 0.1).nil?
    c.puts "hello"
  end
end
