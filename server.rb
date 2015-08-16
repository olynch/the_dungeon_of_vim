require 'socket'
Clients=[]

Clients << TCPServer.new(2000)

loop do
  res = select Clients
  res[0].each do |s|
    if s == Clients[0]
      Clients << s.accept
    elsif s.eof?
      s.close
      Clients.delete(s)
    else
      eval s.gets
    end
  end
end
