require 'termbox'
require './map.rb'

module Display
  @text = ""
  def self.disptext(y, x)
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

  def self.text(str)
    @text << str
  end

  def self.display()
    Termbox.tb_clear
    Maptest::JOHN.display
    Termbox.tb_present
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
