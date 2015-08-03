require 'termbox'
require './helpers.rb'
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

  class NewArea
    attr_accessor :x, :y, :func
    def initialize(x, y, func)
      @x = x
      @y = y
      @func = func
    end

    def display
      @func.call.each do |ch|
        Termbox.tb_change_cell ch.x+@x, ch.y+@y, ch.ord, ch.fg, ch.bg
      end
    end
  end

  class AreaBounded < NewArea
    attr_writer :border, :interior
    def initialize(x, y, func, type, border: nil, interior: nil)
      super x, y, func
      @border = border
      @interior = interior
    end

    def border
      @border || Proc do
        ret = []
        interior = self.interior
        interior.each do |p|
          p.neighborhood.each do |n|
            ret << n unless interior.include? n
          end
        end
        return ret
      end
    end

    def interior
      @interior ||
        self.border.partition {|p| p[0]}.flat_map do |p|
        p.sort {|a, b| a[1] <=> b[1]}
        .each_slice(2).flat_map do |ps|
          if ps.length == 1
            []
          else
            (ps[0][1]+1).upto(ps[1][1]-1).map {|y| [ps[0][0], y]}
          end
        end
      end
    end

    def interior?(p)
      interior.include?(p)
    end

    def display
      @func.call.each do |ch|
        Termbox.tb_change_cell ch.x+@x, ch.y+@y, ch.ord, ch.fg, ch.bg if self.interior? [ch.x, ch.y]
      end
    end
  end

  module DisplayBorder
    def borderDisp
      border.map do |p|
        Char.new(p[0], p[1], ' '.ord, 0, 7)
      end
    end

    def display
      super
      self.borderDisp.each do |ch|
        Termbox.tb_change_cell ch.x+@x, ch.y+@y, ch.ord, ch.fg, ch.bg
      end
    end
  end

  #TODO: MAYBE ADD A METHOD TO AREA THAT JUST RUNS @FUNC.CALL SO THAT WE CAN ADD DIFFERENT WAYS OF INTERPRETING THE DATA FROM @FUNC (LIKE TAIL)

  class AreaWrap < AreaBounded
    #requires that @func only returns Chars at positive coordinates
    def display
      grid=[]
      rows=0
      @func.call.partition {|ch| ch.y}.each do |p| p.each do |ch|
        if self.interior? [ch.x, ch.y+rows]
          Termbox.tb_change_cell ch.x+@x, ch.y+@y+rows, ch.ord, ch.fg, ch.bg
        else
          limit = self.interior.select {|p| p[1] == ch.y+rows}.max {|p| p[0]}
          if limit.nil? then return end
          p.each do |och|
            och.x -= limit[0]
          end
          rows += 1
          redo
        end
      end
      end
    end
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
