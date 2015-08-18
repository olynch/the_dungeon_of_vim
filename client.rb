require 'termbox'
require 'socket'
require './display.rb'
require './helpers.rb'
Termbox.initialize_library
s = TCPSocket.new 'localhost', 2000

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

begin
  Termbox.tb_init
  map = []
  Display::AREAS << Display::AreaRectangle.new([1,1], [21,11], proc{map}, :default)
  loop do
    map = (eval s.gets)[:disp]
    Display.display
    s.puts keyboard_controls
  end
ensure
  s.close
  Termbox.tb_shutdown
end

#STDIN.each_line do |l|
  #if l == "\n" then break end
  #s.puts l
#end
