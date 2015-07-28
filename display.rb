require 'termbox'
require './map.rb'

module Display
  @text = ""
  def Display.disptext(y, x)
    ox = x
    @text.each_char.with_index do |c, i|
      if c == ?\n then
        y+=1
        x = ox
      else
        Termbox.tb_change_cell x, y, c.ord, 1, 0
        x+=1
      end
    end
  end

  def Display.text(str)
    @text << str
  end

  def Display.display()
    Termbox.tb_clear
    Maptest::JOHN.display
    Termbox.tb_present
  end

  class Area
    attr_accessor :x1, :x2, :y1, :y2, :func, :type
    def initialize(a, b, func, type)
      @x0 = a[0]
      @x1 = b[0]
      @y0 = a[1]
      @y1 = b[1]
      @func = func
      @type = type
      @grid = Array.new
    end

    def a
      [@x0, @y0]
    end
    def b
      [@x1, @y1]
    end
    def a=(a)
      @x0 = a[0]
      @y0 = a[1]
    end
    def b=(b)
      @x1 = b[0]
      @y1 = b[1]
    end

    #def update
    #end
    def display
      @func.call.each do |ch|
        if @type == :clip then
          Termbox.tb_change_cell ch.x+x1, ch.y+y1, ch.ord, ch.fg, ch.bg unless ch.x >= @x2-@x1 || ch.y >= @x2-@x1 || ch.x < 0 || ch.y < 0
        end
      end
    end
  end

  class Char
    attr_accessor :x, :y, :fg, :bg, :ch
    def initialize(x, y, ch, fg, bg)
      @x = x
      @y = y
      @ch = ch
      @fg = fg
      @bg = bg
    end
    def ord
      @ch.ord
    end
    def display
      Termbox.tb_change_cell @x, @y, @ch.ord, @fg, @bg
    end
end

class Player
  def display
    if @old_map.nil? then
      @old_map = Map.new(20, 10)
    end

    @old_map.each_square do |s|
      if not self.visible? [s.x, s.y] then
        Termbox.tb_change_cell s.x, s.y, s.ch.ord, 1, 0
      else
        @old_map[s.x, s.y] = Square.new
      end
    end

    self.map.each_square do |s|
      if self.visible? [s.x, s.y] then
        Termbox.tb_change_cell s.x, s.y, s.ch.ord, 4, 0
        s.each {|t| @old_map << t.dup}
      end
    end
  end
end

class Map
  def display
    self.each_square do |s|
      Termbox.tb_change_cell s.x, s.y, s.ch.ord, 4, 0
    end
  end
end
