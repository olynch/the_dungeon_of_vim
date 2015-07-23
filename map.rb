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

  def inspect
    "Player.new(#{@attr}, #{@inventory})"
  end
end

class NilClass
  attr_accessor :x, :y, :map
  def ch
    ' '
  end

  def collision?
    false
  end

  def blocks_vision?
    false
  end

  def collision!(p)
  end
end

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

  def collision!(p)
  end

  def move(dir, amt)
    self.map[self.x, self.y] = nil
    self.send dir + "=", (self.send dir) + amt
    self.map[self.x, self.y] = self
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
    @grid = grid || Array.new(width * height, nil)
    @grid.each.with_index do |thing, i|
      if not thing.nil? then
        thing.map = self; thing.x = i / width; thing.y = i % width
      end
    end
  end

  def [](x, y)
    @grid[x * @height + y] unless x >= @width or x < 0 or y >= @height or y < 0
  end

  def []=(x, y, thing)
    if x >= @width or x < 0 or y >= @height or y < 0 then
      return nil
    end
    unless thing.nil? then
      thing.map = self
      thing.x = x
      thing.y = y
    end
    @grid[x * @height + y] = thing
  end

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
    self.each_thing do |t|
      Termbox.tb_change_cell t.x, t.y, t.ch.ord, 4, 0
    end
  end

  def inspect
    "Map.new(#{@width}, #{@height}, #{@grid})"
  end
end

# map files are just ruby files that declare a module with a MAP constant that is an instance of class
