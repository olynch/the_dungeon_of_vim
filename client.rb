require 'termbox'
require 'socket'
require './display.rb'
require './helpers.rb'
require 'yaml'
Termbox.initialize_library
s = TCPSocket.new 'localhost', 2000
MapData = []

def keyboard_controls
  ev = Termbox::Event.new
  if Termbox.tb_poll_event(ev) >= 0 && ev[:type] == 1 then
    case ev[:key]
    when 0x1B
      exit
    when 0xFFFF-18
      :moveUp
    when 0xFFFF-19
      :moveDown
    when 0xFFFF-20
      :moveLeft
    when 0xFFFF-21
      :moveRight
    end
  end
end

def from_server(s)
  loop do
    MapData.replace (eval s.gets)[:disp]
    Display.display
  end
end

def to_server(s)
  loop do
    s.puts YAML.dump(keyboard_controls)
    s.puts "\n"
  end
end

begin
  Termbox.tb_init
  Display::AREAS << Display::AreaRectangle.new([1,1], [21,11], proc{MapData}, :default)
  [
    Thread.new {from_server(s)},
    Thread.new {to_server(s)}
  ].each(&:join)
ensure
  s.close
  Termbox.tb_shutdown
end


#STDIN.each_line do |l|
  #if l == "\n" then break end
  #s.puts l
#end
