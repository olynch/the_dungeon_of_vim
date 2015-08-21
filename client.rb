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

def debug(str)
  puts "#{Time.now}:#{str}"
end

def from_server(s)
  loop do
      debug "1"
    inp = eval s.gets.chomp
      debug "1.1"
    puts inp
      debug "1.2"
    MapData.replace inp[:disp]
      debug "2"
    Display.display
      debug "3"
  end
end

def to_server(s)
  loop do
    s.puts YAML.dump(keyboard_controls)
    s.puts "\n" #to terminate the message. (make this prettier?)
  end
end

begin
  Termbox.tb_init
  Display::AREAS << Display::AreaRectangle.new([1,1], [21,11], proc{MapData}, :default)
      debug "1"
    inp = eval s.gets.chomp
      debug "1.1"
    puts inp
      debug "1.2"
    MapData.replace inp[:disp]
      debug "2"
    Display.display
      debug "3"
  Thread.new {from_server(s)}
  Thread.new {to_server(s)}
  loop {}
ensure
  s.close
  Termbox.tb_shutdown
end


#STDIN.each_line do |l|
  #if l == "\n" then break end
  #s.puts l
#end
