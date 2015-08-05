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
  Maptest::MAP.each_thing.eager {|t| t.update} #TODO: Make this a thing
end

def win
  exit
end

def main()
  Display::display
  keyboard_controls
end

begin
  Termbox.tb_init
  #Display::AREAS << Display::AreaRectangle.new([10,1], [15,11], Maptest::JOHN.method("disp"))
  Display::AREAS << Display::AreaRectangle.new([1,1], [21,11], Maptest::JOHN.method("disp"))
  Display::AREAS << Display::AreaRectangle.new([23,1], [43,11], Maptest::MAP.method("disp"))
  Display::AREAS << Display::AreaRectangle.new([50,1], [100,50], proc {Display.text.disp})
  #Display::AREAS << Display::Area.new(20, 20, proc{Display.text.disp})
  #Display::AREAS << test = Display::AreaWrap.new(2, 2, proc {Display.text.disp}, border: (-1..10).flat_map {|i| [[i,-1], [-1,i], [10,i], [i,10]]}.uniq)
  loop do
    main
  end
ensure
  Termbox.tb_shutdown
end
