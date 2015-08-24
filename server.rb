require './map.rb'
require './maptest.rb'
require './display.rb'
require 'socket'
require 'json'

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

class DOVServer
  def initialize(port)
    @server = TCPServer.new port
    puts "Started DOV server on port #{port}"
    @clients = [@server]
  end

  def run
    loop do
      (select @clients)[0].each do |s|
        if s == @server
          @clients << @server.accept
          @clients[1..-1].each {|s| s.puts Maptest::JOHN.client_readable.map {|m| [m, Maptest::JOHN.send(m)]}.to_h.to_s}
        elsif s.eof?
          s.close
          @clients.delete(s)
        else
          cmd, *args = JSON.load(s.gets)
          Maptest::JOHN.send(cmd, *args) if Maptest::JOHN.client_callable? cmd.to_sym
          @clients[1..-1].each {|s| s.puts Maptest::JOHN.client_readable.map {|m| [m, Maptest::JOHN.send(m)]}.to_h.to_s}
        end
      end
    end
  end
end

DOVServer.new(2000).run
