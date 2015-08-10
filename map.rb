require './helpers.rb'

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

  def present(t)
  end

  def show_priority
    0
  end

  def move(dir, amt)
    self.map[self.x, self.y].delete(self)
    self.send dir + "=", (self.send dir) + amt
    self.map << self
  end

  def move_to(x, y)
    self.map[self.x, self.y].delete(self)
    self.x = x
    self.y = y
    self.map << self
  end

  def remove
    self.map[self.x, self.y].delete_first(self)
  end

  def inspect
    "Thing.new"
  end

  def update
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

  def show_priority
    10
  end

  def ch
    ?@
  end

  def visible?(p)
    self.map.visible?([self.x, self.y], p)
  end

  def acton(t)
    if t == self
    elsif t.is_a? Key
      self.take t
    elsif t.is_a? Door
      key = @inventory.find_object {|k| k.is_a?(Key) && k.door_name == t.name}
      unless key.nil?
        t.present key
        @inventory.delete_first(key)
      end
    end
  end

  def take(t)
    t.remove
    self << t
  end

  def inspect
    "Player.new(#{@attr}, #{@inventory})"
  end
end

#TODO: maybe have common superclass of Player and Enemy? self.visible? may prove useful
class Enemy < Thing
  def show_priority
    9
  end

  def ch
    ?☹
  end

  def blocks_vision?
    false
  end

  def inspect
    "Enemy.new"
  end

  def update
    where = [["x","y"].sample, [-1,1].sample]
    self.move(*where) unless self.map[*[self.x, self.y].move(*where)].collision?
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

  def present(t)
    if t.is_a?(Key) && t.door_name == self.name
      self.open = true
    end
  end

  def inspect
    "Door.new(#{@name}, #{@open})"
  end
end

class DoorHidden < Door
  def ch
    if @open then ?¦ else ?# end
  end
end

class Map
  attr_accessor :width, :height
  def initialize(width, height, grid=nil)
    @width = width
    @height = height
    @grid = grid || Array.new(width * height) {|_| Square.new}
    @grid.each.with_index do |square, i|
      square.map = self; square.x = i / height; square.y = i % height
    end
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
    if square.is_a? Square then
      @grid[x * @height + y] = square
    elsif square.is_a? Thing then
      @grid[x * @height + y] << square
    end
  end

  def <<(thing)
    if thing.x >= @width or thing.x < 0 or thing.y >= @height or thing.y <0 then
      return nil
    end
    thing.map = self
    if thing.is_a? Square then
      @grid[thing.x * @height + thing.y] = thing
    elsif thing.is_a? Thing then
      @grid[thing.x * @height + thing.y] << thing
    end
  end

  def each_square
    enum_func
    @grid.each do |square|
      yield square unless square == []
    end
  end

  def each_thing
    enum_func
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

  def inspect
    "Map.new(#{@width}, #{@height}, #{@grid})"
  end
end

