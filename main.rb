require 'termbox'
require './maptest.rb'

Termbox.initialize_library

class NilClass
  def block_vision?
    false
  end
  def collision?
    false
  end
end
class Thing
  def block_vision?
    false
  end
  def collision?
    false
  end
end
class Wall
  def block_vision?
    true
  end
  def collision?
    true
  end
end
class Door
  def block_vision?
    true
  end
  def collision?
    true
  end
end
class Player
  def visible?(p)
    self.map.visible?([self.x, self.y], p)
  end
  def display
    if @old_map.nil? then
      @old_map = Map.new(10, 10)
    end

    @old_map.each_thing do |t|
      if not self.visible? [t.x, t.y] then
        Termbox.tb_change_cell t.x, t.y, t.ch.ord, 1, 0
      else
        @old_map[t.x, t.y] = nil
      end
    end

    self.map.each_thing do |t|
      if self.visible?([t.x, t.y]) then
        Termbox.tb_change_cell t.x, t.y, t.ch.ord, 4, 0
        @old_map << t.dup
      end
    end

  end
end

class Map
  attr_accessor :width, :height

  def <<(thing)
    if thing.x >= @width or thing.x < 0 or thing.y >= @height or thing.y <0 then
      return nil
    end
    thing.map = self
    old_thing = @grid[thing.x * @height + thing.y]
    @grid[thing.x * @height + thing.y] = thing
    return old_thing
  end

  def each_thing
    @grid.each do |thing|
      yield thing unless thing.nil?
    end
  end

  def visible?(p0, p1)
    [[0,1], [1,0]].each do |c|
      if p0[c[0]]<p1[c[0]] then
        p0[c[0]].upto(p1[c[0]]-1)
      else p0[c[0]].downto(p1[c[0]]+1)
      end
      .each do |c0|
        c1 =  (((p1[c[1]]-p0[c[1]])*(c0-p0[c[0]])).fdiv(p1[c[0]]-p0[c[0]])+p0[c[1]]) #no divide-by-zero problem because x1.upto(x2-1) won't run anything if x1==x2
        if [[c0, c1.ceil], [c0, c1.floor]].all? do |e| #e for estimate
          self[e[c[0]], e[c[1]]].block_vision?
        end
        then
        return false
        end
      end
    end
    return true
  end

  def display
    self.each_thing do |t|
      Termbox.tb_change_cell t.x, t.y, t.ch.ord, 4, 0
    end
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
      unless Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y-1].collision? then
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = nil
        Maptest::JOHN.y-=1
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = Maptest::JOHN
      end
      #if not collision? $mex, $mey-1 then
        #$map[$mey][$mex]=nil
      #$mey-=1
      #$map[$mey][$mex]=?@
      #end
    when 0xFFFF-19
      unless Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y+1].collision? then
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = nil
        Maptest::JOHN.y+=1
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = Maptest::JOHN
      end
      #if not collision? $mex, $mey+1 then
      #$map[$mey][$mex]=nil
      #$mey+=1
      #$map[$mey][$mex]=?@
      #end
    when 0xFFFF-20
      unless Maptest::MAP[Maptest::JOHN.x-1, Maptest::JOHN.y].collision? then
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = nil
        Maptest::JOHN.x-=1
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = Maptest::JOHN
      end
      #if not collision? $mex-1, $mey then
      #$map[$mey][$mex]=nil
      #$mex-=1
      #$map[$mey][$mex]=?@
      #end
    when 0xFFFF-21
      unless Maptest::MAP[Maptest::JOHN.x+1, Maptest::JOHN.y].collision? then
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = nil
        Maptest::JOHN.x+=1
        Maptest::MAP[Maptest::JOHN.x, Maptest::JOHN.y] = Maptest::JOHN
      end
      #if not collision? $mex+1, $mey then
      #$map[$mey][$mex]=nil
      #$mex+=1
        #$map[$mey][$mex]=?@
      #end
    end
    #case ev[:ch]
    #when ?k.ord
    #$mey-=1
    #when ?j.ord
    #$mey+=1
    #when ?h.ord
    #$mex-=1
    #when ?l.ord
    #$mex+=1
    #end
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
        ev = ["[y-1][x]", "[y][x-1]", "[y][x]", "[y+1][x]", "[y][x+1]"]. map {|x| "buffer" + x}
        ev.keep_if { |a| (eval a).nil? }
        eval (ev.sample + " = ?e")
      end
    end
  end
  $map = buffer
end

def collision?(x, y)
  if $map[y][x] == ?k then $items << "key" end
  if $map[y][x] == ?| && $items.include?("key") then
    $items.delete_at($items.find_index("key"))
    $map[y][x] = nil
  end
  if $map[y][x] == ?* then win end
  return $map[y][x] == ?# || $map[y][x] == ?|
end

def win
  exit
end

def visible?(p0, p1)
  [[0,1], [1,0]].each do |c|
    if p0[c[0]]<p1[c[0]] then
      p0[c[0]].upto(p1[c[0]]-1)
    else p0[c[0]].downto(p1[c[0]]+1)
    end
    .each do |c0|
      c1 =  (((p1[c[1]]-p0[c[1]])*(c0-p0[c[0]])).fdiv(p1[c[0]]-p0[c[0]])+p0[c[1]]) #no divide-by-zero problem because x1.upto(x2-1) won't run anything if x1==x2
      if [[c1.ceil, c0], [c1.floor, c0]].all? do |e|
        ($map[e[c[0]]][e[c[1]]] == ?# || $map[e[c[0]]][e[c[1]]] == ?|)
      end
      then
      return false
      end
    end
  end
  return true
end

def occupied?(x, y)
  return (not ($map[y][x] == nil))
end

def display()
  Termbox.tb_clear
  Maptest::JOHN.display
  #$map.each_index do |y|
    #$map[y].each_index do |x|
      #if not $map[y][x].nil? then
        #if visible? [$mex, $mey], [x, y] then
          #Termbox.tb_change_cell x, y, $map[y][x].ord, 4, 0
          #$map[y][x].instance_variable_set(:@seen, true)
        #elsif $map[y][x].instance_variable_get(:@seen) then
          #Termbox.tb_change_cell x, y, $map[y][x].ord, 1, 0
        #end
      #end
    #end
  #end
  #disptext($map.length, 0)
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
