require './map.rb'
require 'termbox'
Termbox.initialize_library

class Map
  def disp
  Termbox.tb_clear
  @grid.each do |thing|
      if not thing.nil? then
        Termbox.tb_change_cell thing.x, thing.y, thing.ch.ord, 4, 0
      end
    end
  Termbox.tb_present
  end
end
module Maptest
  MAP = Map.new(10, 10)
  0.upto(9) do |i|
    MAP[0, i] = Wall.new
    MAP[9, i] = Wall.new
    MAP[i, 5] = Wall.new
    MAP[i, 0] = Wall.new
    MAP[i, 9] = Wall.new
  end
  MAP[5,5] = nil
  JOHN = Player.new([])
  MAP[2,2] = JOHN
end

#begin
  #Termbox.tb_init
  #loop do
    #Maptest::MAP.disp
  #end
#ensure
  #Termbox.tb_shutdown
#end
