require 'termbox'
require './map.rb'

module Display
  @text = ""
  def Display.text
    @text
  end
  def Display.text=(t)
    @text=t
  end

  def Display.display()
    Termbox.tb_clear
    AREAS.each {|a| a.display}
    Termbox.tb_present
  end

  AREAS=[]

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
      borderColor=7
      (@x0-1).upto(@x1) do |x|
        Termbox.tb_change_cell x, @y0-1, ' '.ord, 0, borderColor
        Termbox.tb_change_cell x, @y1, ' '.ord, 0, borderColor
      end
      (@y0-1).upto(@y1) do |y|
        Termbox.tb_change_cell @x0-1, y, ' '.ord, 0, borderColor
        Termbox.tb_change_cell @x1, y, ' '.ord, 0, borderColor
      end
      @func.call.each do |ch|
        if @type == :clip then
          Termbox.tb_change_cell ch.x+@x0, ch.y+@y0, ch.ord, ch.fg, ch.bg unless ch.x >= @x1-@x0 || ch.y >= @y1-@y0 || ch.x < 0 || ch.y < 0
        end
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
  def disp
    ret = []
    if @old_map.nil? then
      @old_map = Map.new(20, 10)
    end

    @old_map.each_square do |s|
      if not self.visible? [s.x, s.y] then
        ret << Char.new(s.x, s.y, s.ch.ord, 1, 0)
      else
        @old_map[s.x, s.y] = Square.new
      end
    end

    self.map.each_square do |s|
      if self.visible? [s.x, s.y] then
        ret << Char.new(s.x, s.y, s.ch.ord, 4, 0)
        s.each {|t| @old_map << t.dup}
      end
    end
    return ret
  end
end

class String
  def disp
    ret=[]
    x=0
    y=0
    self.each_char do |c|
      case c
      when ?\n
        y+=1
        x=0
      else
        ret << Char.new(x, y, c.ord, 0, 0)
        x+=1
      end
    end
    return ret
  end
end

class Map
  def disp
    ret=[]
    self.each_square do |s|
      ret << Char.new(s.x, s.y, s.ch.ord, 4, 0)
    end
    return ret
  end
end
