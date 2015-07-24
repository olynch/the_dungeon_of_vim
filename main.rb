require './helpers.rb'
require './display.rb'
require 'termbox'
require './maptest.rb'

Termbox.initialize_library

def parse_dun(fn)
  File.open(fn, ?r) do |f|
    return f.each_line.map do |ln|
      ln.each_char.map do |c|
        if [?#, ?@, ?k, ?|, ?*, ?e].include? c then
          c
        else
          nil
        end
      end
    end
  end
end


def keyboard_controls()
  ev = Termbox::Event.new
  if Termbox.tb_poll_event(ev) >= 0 && ev[:type] == 1 then
    ox = Maptest::JOHN.x
    oy = Maptest::JOHN.y
    case ev[:key]
    when 0x1B
      exit
    when 0xFFFF-18
      #Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y-1].collision! Maptest::JOHN
      #unless Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y-1].collision? then
        Maptest::JOHN.move(?y, -1)
      #end
    when 0xFFFF-19
      #Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y+1].collision! Maptest::JOHN
      #unless Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y+1].collision? then
        Maptest::JOHN.move(?y, 1)
      #end
    when 0xFFFF-20
      #Maptest::MAP[Maptest::JOHN.x-1, Maptest::JOHN.y].collision! Maptest::JOHN
      #unless Maptest::MAP[Maptest::JOHN.x-1, Maptest::JOHN.y].collision? then
        Maptest::JOHN.move(?x, -1)
      #end
    when 0xFFFF-21
      #Maptest::MAP[Maptest::JOHN.x+1, Maptest::JOHN.y].collision! Maptest::JOHN
      #unless Maptest::MAP[Maptest::JOHN.x+1, Maptest::JOHN.y].collision? then
        Maptest::JOHN.move(?x, 1)
      #end
    end
    Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y].each do |t|
      Maptest::JOHN.acton(t)
    end
    if Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y].collision?
      Maptest::JOHN.move_to(ox, oy)
    end
  end
  #Maptest::MAP.each_thing {|t| t.update} #TODO: Make this a thing
end

#def move_enemy()
  #buffer = []
  #buffer = $map.map { |x| x.map {|y| y}}
  #$map.each_index do |y|
    #$map[y].each_index do |x|
      #if $map[y][x] == ?e then
        #buffer[y][x] = nil
        #ev = ["[y-1][x]", "[y][x-1]", "[y][x]", "[y+1][x]", "[y][x+1]"].map {|x| "buffer" + x}
        #ev.keep_if { |a| (eval a).nil? }
        #eval (ev.sample + " = ?e")
      #end
    #end
  #end
  #$map = buffer
#end

def win
  exit
end

def main()
  Display::text "hello, world\n"
  Display::display
  keyboard_controls
end

begin
  Termbox.tb_init
  loop do
    main
  end
ensure
  Termbox.tb_shutdown
end
