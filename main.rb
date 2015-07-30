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
        Maptest::JOHN.move(?y, -1)
    when 0xFFFF-19
        Maptest::JOHN.move(?y, 1)
    when 0xFFFF-20
        Maptest::JOHN.move(?x, -1)
    when 0xFFFF-21
        Maptest::JOHN.move(?x, 1)
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
  Display.text << "#{Maptest::JOHN.x}, #{Maptest::JOHN.y}\n"
  Display::display
  keyboard_controls
end

begin
  Termbox.tb_init
  #Display::AREAS << Display::Area.new([10,1], [15,11], Maptest::JOHN.method("disp"), :clip)
  #Display::AREAS << Display::Area.new([20,20], [40,30], Maptest::MAP.method("disp"), :clip)
  #Display::AREAS << Display::Area.new([50,1], [100,50], proc {Display.text.disp}, :clip)
  Display::AREAS << Display::ClipArea.new(2, 2, proc {Display.text.disp}, border: (1..10).flat_map {|i| [[i,1], [1,i], [10,i], [i,10]]}.uniq)
  loop do
    main
  end
ensure
  Termbox.tb_shutdown
end
