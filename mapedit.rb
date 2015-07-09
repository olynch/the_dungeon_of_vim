class Thing
	attr_accessor :map, :y, :x
	def ch
		nil
	end
end

class Player < Thing
	def initialize(attr)
		@attr = attr
	end

	def ch
		?@
	end
end

class Wall < Thing
	def initialize
	end

	def ch
		?#
	end
end

class Key < Thing
	def initialize(door)
		@door = door
	end

	def open
		@door.open
	end

	def ch
		?k
	end
end

class Door < Thing
	attr_accessor :open
	def initialize
		@open = false
	end

	def ch
		if @open ?| else nil end
	end
end

class Map
	def initialize(y, x, me)
		@grid = Array.new(y * x)
		@ydim = y
		@xdim = x
	end

	def [](y, x)
		@grid[y * @xdim + x]
	end

	def []=(y, x, thing)
		thing.map = self
		thing.y = y
		thing.x = x
		@grid[y * @xdim + x] = thing
	end
end
