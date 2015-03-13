require 'ncursesw'


class Dungeon

	def each(&block)
		@grid.each do |row|
			row.each do |thing|
				yield thing unless thing.nil?
			end
		end
	end
	
	def initialize(dun_file)
		@grid = parse_dungeon dun_file, self
		@dimy = @grid.length
		@dimx = @grid[0].length
	end

	# precondition: 0 <= y1, y2 < @dimy, 0 <= x1, x2 < @dimx
	def move(y1, x1, y2, x2)
		if not @grid[y1][x1].nil? and @grid[y2][x2].nil?
			move_thing = @grid[y1][x1]
			move_thing.y, move_thing.x = y2, x2
			@grid[y2][x2] = move_thing
			@grid[y1][x1] = nil
			return true
		else
			return false
		end
	end

	def <<(thing)
		y, x = thing.y, thing.x
		if (0 <= y and y < @dimy) and (0 <= x and y < @dimx) and @grid[y][x].nil?
			@grid[y][x] = thing
			return true
		else
			return false
		end
	end
end

class DungeonThing
	attr_accessor :y, :x, :label

	def initialize(y, x, label, parent_dun) 
		@y = y
		@x = x
		@label = label
		@dun = parent_dun
	end

end

class Player < DungeonThing
	
	def initialize(y, x, parent_dun)
		super(y, x, '@', parent_dun)
	end

end

class Wall < DungeonThing

	def initialize(y, x, parent_dun)
		super(y, x, '#', parent_dun)
	end

end

def draw_dungeon(dun, scr)
	scr.clear
	dun.each do |thing|
		scr.mvaddch thing.y, thing.x, thing.label.ord
	end
	scr.refresh
end

def parse_dungeon(dun_file_name, dun)
	File.open(dun_file_name, "r") do |dun_file|
		dun_file.each_line().with_index().map do |ln, y|
			ln.each_char().with_index().map do |c, x|
				case c
				when ?#
					Wall.new y, x, dun
				else
					nil
				end
			end
		end
	end
end

begin
	scr = Ncurses.initscr
	Ncurses.cbreak # accept every char without having to hit \n
	Ncurses.curs_set 0 # don't show the cursor
	log = "LOG:\n"

	Signal.trap("INT") do
		Ncurses.endwin
		puts "INT RECEIVED"
		puts log
		exit
	end

	dun = Dungeon.new("dungeon.txt")
	p = Player.new 1, 1, dun
	dun << p
	draw_dungeon(dun, scr)

	loop do
		c = Ncurses.getch().chr
		new_y, new_x = p.y, p.x
		case c
		when ?k
			new_y -= 1
		when ?j
			new_y += 1
		when ?h 
			new_x -= 1
		when ?l
			new_x += 1
		when ?q
			break
		end
		dun.move(p.y, p.x, new_y, new_x)
		draw_dungeon(dun, scr)
	end
ensure
	Ncurses.endwin
end
