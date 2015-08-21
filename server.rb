require './map.rb'
require './maptest.rb'
require './display.rb'
require 'socket'
require 'yaml'

module ClientBehavior
  def client_callable?(sym)
    @client_callable = [:i_move]
    @client_callable.include? sym
  end
  def client_readable
    @client_readable = [:inventory, :disp]
    @client_readable
  end
end

class Player
  include ClientBehavior
  def i_move(where)
    dir = where[0]
    amt = (where[1] + "1").to_i
    whereTo = [self.x, self.y].move(dir, amt)
    self.move(dir, amt) unless self.map[*whereTo].collision?
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
      Clients[1..-1].each {|s| s.puts Maptest::JOHN.client_readable.map {|m| [m, Maptest::JOHN.send(m)]}.to_h.to_s}
    elsif s.eof?
      s.close
      Clients.delete(s)
    else
      cmd, *args = YAML.load(s.gets "")
      Maptest::JOHN.send(cmd, *args) if Maptest::JOHN.client_callable? cmd
      Clients[1..-1].each {|s| s.puts Maptest::JOHN.client_readable.map {|m| [m, Maptest::JOHN.send(m)]}.to_h.to_s}
    end
  end
end

