require './map.rb'
require './maptest.rb'
require './display.rb'
require 'socket'

module ClientBehavior
  def client_callable?(sym)
    @client_callable = [:moveUp]
    @client_callable.include? sym
  end
  def client_readable
    @client_readable = [:inventory, :disp]
    @client_readable
  end
end

class Player
  include ClientBehavior
  def moveUp
    whereTo = [self.x, self.y].move(?y, -1)
    self.move(?y, -1) unless self.map[*whereTo].collision?
    self.map[*whereTo].each {|t| self.acton(t)}
  end
end

Clients=[]

Clients << TCPServer.new(2000)

env = binding

loop do
  res = select Clients
  res[0].each do |s|
    if s == Clients[0]
      Clients << s.accept
      Clients[-1].puts Maptest::JOHN.client_readable.map {|m| [m, Maptest::JOHN.send(m)]}.to_h.to_s
    elsif s.eof?
      s.close
      Clients.delete(s)
    else
      cmd = s.gets.chomp.to_sym
      p cmd
      Maptest::JOHN.send cmd if Maptest::JOHN.client_callable? cmd
      s.puts Maptest::JOHN.client_readable.map {|m| [m, Maptest::JOHN.send(m)]}.to_h.to_s
    end
  end
end

