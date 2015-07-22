require 'termbox'
require './maptest.rb'

Termbox.initialize_library

class Thing
  def collision!(p)
  end
end

class Key
  def collision!(p)
    p << self
  end
end

class Door
  def collision!(p)
    if p.inventory.find_index {|k| k.is_a?(Key) && k.door_name == self.name}
      self.open = true
    end
  end
end

class NilClass
  def collision!(p)
  end
end

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

$map = parse_dun("dungeon.txt")

$items = []

$text = ""


$mey = $map.index { |r| $mex = r.index { |x| x == ?@ } }

def keyboard_controls()
  ev = Termbox::Event.new
  if Termbox.tb_poll_event(ev) >= 0 && ev[:type] == 1 then
    case ev[:key]
    when 0x1B
      exit
    when 0xFFFF-18
      Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y-1].collision! Maptest::JOHN
      unless Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y-1].collision? then
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = nil
        Maptest::JOHN.y-=1
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = Maptest::JOHN
      end
    when 0xFFFF-19
      Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y+1].collision! Maptest::JOHN
      unless Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y+1].collision? then
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = nil
        Maptest::JOHN.y+=1
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = Maptest::JOHN
      end
    when 0xFFFF-20
      Maptest::MAP[Maptest::JOHN.x-1, Maptest::JOHN.y].collision! Maptest::JOHN
      unless Maptest::MAP[Maptest::JOHN.x-1, Maptest::JOHN.y].collision? then
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = nil
        Maptest::JOHN.x-=1
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = Maptest::JOHN
      end
    when 0xFFFF-21
      Maptest::MAP[Maptest::JOHN.x+1, Maptest::JOHN.y].collision! Maptest::JOHN
      unless Maptest::MAP[Maptest::JOHN.x+1, Maptest::JOHN.y].collision? then
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = nil
        Maptest::JOHN.x+=1
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = Maptest::JOHN
      end
    end
    move_enemy
  end
end

def text(str)
  $text << str
end

def move_enemy()
  buffer = []
  buffer = $map.map { |x| x.map {|y| y}}
  $map.each_index do |y|
    $map[y].each_index do |x|
      if $map[y][x] == ?e then
        buffer[y][x] = nil
        ev = ["[y-1][x]", "[y][x-1]", "[y][x]", "[y+1][x]", "[y][x+1]"].map {|x| "buffer" + x}
        ev.keep_if { |a| (eval a).nil? }
        eval (ev.sample + " = ?e")
      end
    end
  end
  $map = buffer
end

def win
  exit
end

def display()
  Termbox.tb_clear
  Maptest::JOHN.display
  Termbox.tb_present
end

def disptext(y, x)
  ox = x
  $text.each_char.with_index do |c, i|
    if c == ?\n then
      y+=1
      x = ox
    else
      Termbox.tb_change_cell x, y, c.ord, 1, 0
      x+=1
    end
  end
end

def main()
  text "hello, world\n"
  display
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
