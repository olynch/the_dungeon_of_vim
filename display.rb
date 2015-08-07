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
    AREAS.each {|a| a.display; a.sudo_display}
    Termbox.tb_present
  end

  AREAS=[]

  #requires that @func only returns Chars at positive coordinates
  #and returns lines in increasing order
  #also AreaBounded
  Wrap = Proc.new do
    rows=0
    @func.call.partition {|ch| ch.y}.each do |p| p.each do |ch|
      if self.interior? [ch.x, ch.y+rows]
        Termbox.tb_change_cell ch.x+@x, ch.y+@y+rows, ch.ord, ch.fg, ch.bg
      else
        limit = self.interior.select {|p| p[1] == ch.y+rows}.max {|p| p[0]}
        if limit.nil? then return nil end
        p.each do |och|
          och.x -= limit[0]
        end
        rows += 1
        redo
      end
    end
    end
  end

  Clip = Proc.new do
    @func.call.each do |ch|
      Termbox.tb_change_cell ch.x+@x, ch.y+@y, ch.ord, ch.fg, ch.bg if self.interior? [ch.x, ch.y]
    end
  end

  module AreaTail
    def self.extend_object(base)
      base.extend(AreaWrap)
      base.instance_variable_set(:@linesShift, 0)
      super
    end

    def func_lines
      super.reverse
    end

    def display
      @func.call.partition {|ch| ch.y}.reverse.each do |part|
        part[-1].xjj
      end
    end
  end

  class Area
    attr_accessor :x, :y, :func, :sudo_func
    def initialize(x, y, func, display, sudo_func=proc{[]})
      @x = x
      @y = y
      @func = func
      @sudo_func = sudo_func
      define_singleton_method(:display, display) unless display == :default
    end

    def display
      @func.call.each do |ch|
        Termbox.tb_change_cell ch.x+@x, ch.y+@y, ch.ord, ch.fg, ch.bg
      end
    end

    def sudo_display
      @sudo_func.call.each do |ch|
        Termbox.tb_change_cell ch.x+@x, ch.y+@y, ch.ord, ch.fg, ch.bg
      end
    end
  end

  module DisplayBorder
    def self.extended(base)
      tempfunc = base.sudo_func #TODO: This is ugly. Make it not ugly.
      base.sudo_func = proc {tempfunc.call | base.borderDisp}
    end

    def borderDisp
      border.map do |p|
        Char.new(p[0], p[1], ' '.ord, 0, 7)
      end
    end
  end

  class AreaBounded < Area
    attr_writer :border, :interior
    def initialize(x, y, func, display, sudo_func=proc{[]}, border: nil, interior: nil, dispBorder: true)
      super x, y, func, display, sudo_func
      @border = border
      @interior = interior
      self.extend DisplayBorder if dispBorder
    end

    def border
      @border || proc do
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

    define_method(:display, Display::Clip)
  end

  #TODO: MAYBE ADD A METHOD TO AREA THAT JUST RUNS @FUNC.CALL SO THAT WE CAN ADD DIFFERENT WAYS OF INTERPRETING THE DATA FROM @FUNC (LIKE TAIL)

  class AreaRectangle < AreaBounded
    attr_reader :a, :b
    def initialize(a, b, func, display, sudo_func=proc{[]}, dispBorder: true)
      super a[0], a[1], func, display, sudo_func, dispBorder: dispBorder
      @a = a
      @b = b
      @border = border
      @interior = interior
    end

    def a=(a)
      @a = a
      @x = a[0]
      @y = a[1]
    end

    def b=(b)
      @b = b
    end

    def h
      @b[1]-@a[1]
    end

    def w
      @b[0]-@a[0]
    end

    def border
      ((-1..w).flat_map {|i| [[i, -1], [i, h]]} |
       (-1..h).flat_map {|i| [[-1, i], [w, i]]} )
      .uniq
    end

    def interior
      (0..w-1).to_a.product (0..h-1).to_a
    end

    def interior?(xy)
      xy[0] >= 0 && xy[0] < w && xy[1] >= 0 && xy[1] < w
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
