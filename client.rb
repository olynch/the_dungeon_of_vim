require 'termbox'
require 'socket'
require './display.rb'
require './helpers.rb'
require 'json'
Termbox.initialize_library

def keyboard_controls
  ev = Termbox::Event.new
  if Termbox.tb_poll_event(ev) >= 0 && ev[:type] == 1 then
    case ev[:key]
    when 0x1B
      exit
    when 0xFFFF-18
      [:i_move, 'y-']
    when 0xFFFF-19
      [:i_move, 'y+']
    when 0xFFFF-20
      [:i_move, 'x-']
    when 0xFFFF-21
      [:i_move, 'x+']
    end
  end
end

class DOVClient
  attr_accessor :data
  def initialize(port)
    @server = TCPSocket.new 'localhost', port
    @data = {}
  end

  def run
    [
      Thread.new {from_server},
      Thread.new {to_server}
    ].map(&:join)
  end

  def close
    @server.close
  end

  private
  def from_server
    loop do
      @data.replace eval(@server.gets.chomp)
      Display::display
    end
  end

  def to_server
    loop do
      @server.puts JSON.dump(keyboard_controls)
    end
  end

end

begin
  Termbox.tb_init
  c = DOVClient.new(2000)
  Display::AREAS << Display::AreaRectangle.new([1,1], [21,11], proc{c.data[:disp]}, :default)
  c.run
ensure
  c.close
  Termbox.tb_shutdown
end
