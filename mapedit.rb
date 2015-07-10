require './map.rb'

$map = Map.new(10, 10)
$maps = [map]
$mode = :normal
# :normal, :edit, :command

class Command
end

def process_events

end

def display
  
end

def main
  process_events
  display
end
 
begin
  Termbox.tb_init
  loop do
    main
  end
ensure
  Termbox.tb_shutdown
end
