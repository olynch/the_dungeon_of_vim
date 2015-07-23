class Square < Array
  attr_accessor :x, :y, :map
  def ch
    if self == [] then
      return ' '
    else
      self.reverse.max_by {|t| t.show_priority}.ch
    end
  end

  def x=(x)
    self.each {|t| t.x=x}
    @x=x
  end

  def y=(y)
    self.each {|t| t.y=y}
    @y=y
  end

  def <<(t)
    t.x = self.x
    t.y = self.y
    t.map = self.map
    super
  end

  def collision?
    self.any? {|t| t.collision?}
  end

  def collision!(p)
    self.each {|t| t.collision! p}
  end

  def map=(map)
    self.each {|t| t.map=map}
    @map = map
  end

  def blocks_vision?
    self.any? {|t| t.blocks_vision?}
  end
end

class Thing
  attr_accessor :map, :x, :y
  def ch
    nil
  end

  def collision?
    false
  end

  def blocks_vision?
    false
  end

  def collision!(p)
  end

  def move(dir, amt)
    self.map[self.x, self.y].delete(self)
    self.send dir + "=", (self.send dir) + amt
    self.map << self
  end

  def inspect
    "Thing.new"
  end
end

class Player < Thing
  attr_accessor :inventory
  def initialize(attr, inventory = nil)
    @attr = attr
    @inventory = inventory || []
  end

  def <<(thing)
    @inventory.push(thing)
  end

  def ch
    ?@
  end

  def visible?(p)
    self.map.visible?([self.x, self.y], p)
  end

  def display
    if @old_map.nil? then
      @old_map = Map.new(20, 10)
    end

puts("I:")
self.map.p_e

    @old_map.each_square do |s|
      if not self.visible? [s.x, s.y] then
        Termbox.tb_change_cell s.x, s.y, s.ch.ord, 1, 0
      else
        @old_map[s.x, s.y] = Square.new
      end
    end

puts("II:")
self.map.p_e

    self.map.each_square do |s|
      if self.visible? [s.x, s.y] then
        Termbox.tb_change_cell s.x, s.y, s.ch.ord, 4, 0
        @old_map << s.dup
      end
    end
puts("III:")
self.map.p_e
  end

  def inspect
    "Player.new(#{@attr}, #{@inventory})"
  end
end

#class NilClass
  #attr_accessor :x, :y, :map
  #def ch
    #' '
  #end

  #def collision?
    #false
  #end

  #def blocks_vision?
    #false
  #end

  #def collision!(p)
  #end
#end

class Wall < Thing
  def initialize
  end

  def ch
    ?#
  end

  def blocks_vision?
    true
  end

  def collision?
    true
  end

  def inspect
    "Wall.new"
  end
end

class Key < Thing
  attr_reader :door_name
  def initialize(door_name)
    @door_name = door_name
  end

  def ch
    ?Ƒ
  end

  def collision!(p)
    p << self
  end

  def inspect
    "Key.new(#{@door_name})"
  end
end

class Door < Thing
  attr_accessor :open
  attr_reader :name
  def initialize(name, open=false)
    @name = name
    @open = open
  end

  def ch
    if @open then ?¦ else ?| end
  end

  def blocks_vision?
    !@open
  end

  def collision?
    !@open
  end

  def collision!(p)
    if p.inventory.find_index {|k| k.is_a?(Key) && k.door_name == self.name}
      self.open = true
    end
  end

  def inspect
    "Door.new(#{@name}, #{@open})"
  end
end

class Map
  attr_accessor :width, :height
  def initialize(width, height, grid=nil)
    @width = width
    @height = height
    @grid = grid || Array.new(width * height, Square.new)
    @grid.each.with_index do |square, i|
      square.map = self; square.x = i / height; square.y = i % height
      puts square.x
    end
    puts("BEFORE_FIRST")
    self.p_e
  end

  def [](x, y)
    if x < @width and x >= 0 and y < @height and y >= 0 then
      @grid[x * @height + y]
    else
      Square.new
    end
  end

  def []=(x, y, square)
    if x >= @width or x < 0 or y >= @height or y < 0 then
      return nil
    end
    square.map = self
    square.x = x
    square.y = y
    @grid[x * @height + y] = square
  end

  def <<(thing)
    if thing.x >= @width or thing.x < 0 or thing.y >= @height or thing.y <0 then
      return nil
    end
    thing.map = self
    #old_thing = @grid[thing.x * @height + thing.y]
    if thing.is_a? Square then
      @grid[thing.x * @height + thing.y] = thing
    elsif thing.is_a? Thing then
      @grid[thing.x * @height + thing.y] << thing
    end
    #return old_thing
  end

  def p_e
    @grid.each do |s|
      print s.x
      print ", "
      print s.y
      puts
    end
  end

  def each_square
    @grid.each do |square|
      yield square unless square == []
    end
  end

  def each_thing
    @grid.each do |square|
      square.each do |thing|
        yield thing unless thing.nil?
      end
    end
  end

  def visible?(p0, p1)
    [[0,1], [1,0]].each do |c|
      if p0[c[0]]<p1[c[0]] then
        p0[c[0]].upto(p1[c[0]]-1)
      else
        p0[c[0]].downto(p1[c[0]]+1)
      end
      .each do |c0|
        c1 =  (((p1[c[1]]-p0[c[1]])*(c0-p0[c[0]])).fdiv(p1[c[0]]-p0[c[0]])+p0[c[1]]) #no divide-by-zero problem because x1.upto(x2-1) won't run anything if x1==x2
        if [[c0, c1.ceil], [c0, c1.floor]].all? do |e| #e for estimate
            self[e[c[0]], e[c[1]]].blocks_vision?
          end
        then
          return false
        end
      end
    end
    return true
  end

  def display
    self.each_square do |s|
      Termbox.tb_change_cell s.x, s.y, s.ch.ord, 4, 0
    end
  end

  def inspect
    "Map.new(#{@width}, #{@height}, #{@grid})"
  end
end

