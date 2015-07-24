require './map.rb'
require 'termbox'
Termbox.initialize_library

#class Map
  #def disp
  #Termbox.tb_clear
  #@grid.each do |thing|
      #if not thing.nil? then
        #Termbox.tb_change_cell thing.x, thing.y, thing.ch.ord, 4, 0
      #end
    #end
  #Termbox.tb_present
  #end
#end
module Maptest
  MAP = Map.new(20, 10)
  0.upto(9) do |i|
    MAP[0, i] = Square.new [Wall.new]
    MAP[9, i] = Square.new [Wall.new]
    MAP[i, 5] = Square.new [Wall.new]
    MAP[i, 0] = Square.new [Wall.new]
    MAP[i, 9] = Square.new [Wall.new]
    MAP[i+9, 0] = Square.new [Wall.new]
    MAP[i+9, 9] = Square.new [Wall.new]
    MAP[19, i] = Square.new [Wall.new]
  end
  MAP[5,5] = Square.new
  MAP[9,6] = Square.new [Door.new("door")]
  MAP[3,8] = Square.new [Key.new("door")]
  JOHN = Player.new([])
  MAP[2,2] = Square.new [JOHN]
end


#begin
  #Termbox.tb_init
  #loop do
    #Maptest::MAP.disp
  #end
#ensure
  #Termbox.tb_shutdown
#end
