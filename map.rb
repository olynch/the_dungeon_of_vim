class Thing
  attr_accessor :map, :x, :y
  def ch
    nil
  end
end

class Player < Thing
  def initialize(attr, inventory = nil)
    @attr = attr
    @inventory = if inventory then inventory else [] end
  end

  def give(thing)
    @inventory.push(thing)
  end

  def ch
    ?@
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
end

class Wall < Thing
  def initialize
  end

  def ch
    ?#
  end

  def inspect
    "Wall.new"
  end
end

class Key < Thing
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
    if @open then ?| else ?¦ end
  end

  def inspect
    "Door.new(#{@name}, #{@open})"
  end
end

class Map
  def initialize(width, height, grid=nil)
    @width = width
    @height = height
    @grid = grid ? grid : Array.new(width * height, nil)
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

  def inspect
    "Map.new(#{@width}, #{@height}, #{@grid})"
  end
end

# map files are just ruby files that declare a module with a MAP constant that is an instance of class
