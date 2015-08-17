require 'termbox'
require 'socket'
require './display.rb'
require './helpers.rb'
Termbox.initialize_library
s = TCPSocket.new 'localhost', 2000
begin
  Termbox.tb_init
  map = []
  Display::AREAS << Display::AreaRectangle.new([1,1], [21,11], proc{map}, :default)
  loop do
    map = (eval s.gets)[:disp]
    Display.display
  end
ensure
  s.close
  Termbox.tb_shutdown
end

#STDIN.each_line do |l|
  #if l == "\n" then break end
  #s.puts l
#end
