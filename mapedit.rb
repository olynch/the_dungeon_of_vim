require './map.rb'
require './display.rb'

$cur = MapBuffer.new(Map.new(10,) 10)
$buffers = [cur]

class MapBuffer
  #attr_accessor :cursor, :mode, :history, :command, :map

  def initialize(map)
    @map = map
    @cursor = { x: 0, y: 0}
    @history = []
    @command = ""
    @command_res = ""
    @mode = :normal
  end

  def disp_buffer
    added_cursor = false
    ret = @map.disp.map do |ch|
      if ch.x == cursor.x and ch.y == cursor.y
        Char.new(ch.x, ch.y, ch.ch, ch.bg, ch.fg) # flip bg and fg
        added_cursor = true
      else
        ch
      end
    end
    if not added_cursor
      ret << Char.new(cursor.x, cursor.y, ' ', 0x08, 0x08) # 0x08 is white
    end
    return ret
  end

  def disp_command
    if @command != ""
      (":" + @command).disp
    else
      @command_res.disp
    end
  end

  def disp_mode
    @mode.to_s.disp
  end

  def send_key key
    case @mode
    when :normal
      case key
      when ?h.ord
        @cursor.x -= 1 unless @cursor.x == 0
      when ?j.ord
        @cursor.y += 1 unless @cursor.y == $map.height - 1
      when ?k.ord
        @cursor.y -= 1 unless @cursor.y == 0
      when ?l.ord
        @cursor.x += 1 unless @cursor.x == $map.width - 1
      when ?i.ord
        @mode = :edit
      when ?:.ord
        @mode = :command
    end
    when :edit
      case key
      when 27 # key code for escape
        @mode = :normal
    when :command
      case key
      when ?\n.ord
        eval $command
        @history.add(@command)
        @mode = :normal
        @command = ""
      when 27
        @command = ""
      else
        @command += key
      end
    end
  end
end
# :normal, :edit, :command

# Description
# Cursor moves around with hjkl
# use i to edit the contents of a square
# use esc to get out of edit mode
# use : to go into command mode, which is just a repl

def process_events
  ev = Termbox::Event.new
  if Termbox.tb_poll_event(ev) >= 0 && ev[:type] == 1 then
    $cur.send_key(ev[:key])
  end
end

def main
  Display::display
  process_events
end
 
begin
  Termbox.tb_init
  Display::AREAS << Display::AreaRectangle.new([1,1], [11,11], $cur.method("disp_buffer"), :default)
  Display::AREAS << Display::AreaRectangle.new([1, 20], [20, 20], $cur.method("disp_command"), :default, dispBorder: false)
  Display::AREAS << Display::AreaRectangle.new([1, 19], [20, 19], $cur.method("disp_mode"), :default, dispBorder: false)
  loop do
    main
  end
ensure
  Termbox.tb_shutdown
end
