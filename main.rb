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
    case ev[:key]
    when 0x1B
      exit
    when 0xFFFF-18
      move = true
      where = [?y, -1]
    when 0xFFFF-19
      move = true
      where = [?y, 1]
    when 0xFFFF-20
      move = true
      where = [?x, -1]
    when 0xFFFF-21
      move = true
      where = [?x, 1]
    end
    if move
      whereto = [Maptest::JOHN.x, Maptest::JOHN.y].move(*where)
      Maptest::JOHN.move(*where) unless Maptest::MAP[*whereto].collision?
      Maptest::MAP[*whereto].each do |t|
        Maptest::JOHN.acton(t)
      end
    end
  end
  Maptest::MAP.each_thing.eager {|t| t.update} #TODO: Make this a thing
end

def win
  exit
end

def main()
  if @n.nil? then @n = 0 end
  Display.text << "#{@n} Hello, world. This is a long paragraph so that it gets split accross multiple lines. Maybe even three if we're lucky? Pretty please?\n"
  @n+=1
  Display::display
  keyboard_controls
end

begin
  Termbox.tb_init
  #Display::AREAS << Display::AreaRectangle.new([10,1], [15,11], Maptest::JOHN.method("disp"))
  #Display::AREAS << Display::AreaRectangle.new([1,1], [21,11], Maptest::JOHN.method("disp"), :default)
  Display::AREAS << test= Display::AreaCircle.new(10,10, 5, Maptest::JOHN.method("disp"), :default)
  #Display::AREAS << Display::AreaRectangle.new([23,1], [43,11], Maptest::MAP.method("disp"), :default)
  #Display::AREAS << Display::AreaRectangle.new([50,1], [100,50], proc {Display.text.disp}, Display::Shift << Display::Clip << Display::Tail << Display::Wrap)
  #Display::AREAS << Display::Area.new(20, 20, proc{Display.text.disp})
  #Display::AREAS << test = Display::AreaWrap.new(2, 2, proc {Display.text.disp}, border: (-1..10).flat_map {|i| [[i,-1], [-1,i], [10,i], [i,10]]}.uniq)
  p test.border
  loop do
    main
  end
ensure
  Termbox.tb_shutdown
end
