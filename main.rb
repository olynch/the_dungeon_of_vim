require 'termbox'

Termbox.initialize_library

def parse_dun(fn)
  File.open(fn, ?r) do |f|
    return f.each_line.map do |ln|
      ln.each_char.map do |c|
        if [?#, ?@, ?k, ?|, ?*, ?e].include? c then
          c
        else
          nil
        end
      end
    end
  end
end

$map = parse_dun("dungeon.txt")

$items = []


$mey = $map.index { |r| $mex = r.index { |x| x == ?@ } }

def keyboard_controls()
  ev = Termbox::Event.new
  if Termbox.tb_poll_event(ev) >= 0 && ev[:type] == 1 then
    case ev[:key]
    when 0x1B
      exit
    when 0xFFFF-18
      if not collision? $mex, $mey-1 then
        $map[$mey][$mex]=nil
        $mey-=1
        $map[$mey][$mex]=?@
      end
    when 0xFFFF-19
      if not collision? $mex, $mey+1 then
        $map[$mey][$mex]=nil
        $mey+=1
        $map[$mey][$mex]=?@
      end
    when 0xFFFF-20
      if not collision? $mex-1, $mey then
        $map[$mey][$mex]=nil
        $mex-=1
        $map[$mey][$mex]=?@
      end
    when 0xFFFF-21
      if not collision? $mex+1, $mey then
        $map[$mey][$mex]=nil
        $mex+=1
        $map[$mey][$mex]=?@
      end
    end
    #case ev[:ch]
    #when ?k.ord
    #$mey-=1
    #when ?j.ord
    #$mey+=1
    #when ?h.ord
    #$mex-=1
    #when ?l.ord
    #$mex+=1
    #end
    move_enemy
  end
end

def move_enemy()
  buffer = []
  buffer = $map.map { |x| x.map {|y| y}}
  $map.each_index do |y|
    $map[y].each_index do |x|
      if $map[y][x] == ?e then
        buffer[y][x] = nil
        ev = ["[y-1][x]", "[y][x-1]", "[y][x]", "[y+1][x]", "[y][x+1]"]. map {|x| "buffer" + x}
        ev.keep_if { |a| (eval a).nil? }
        eval (ev.sample + " = ?e")
      end
    end
  end
  $map = buffer
end

def collision?(x, y)
  if $map[y][x] == ?k then $items << "key" end
  if $map[y][x] == ?| && $items.include?("key") then
    $items.delete_at($items.find_index("key"))
    $map[y][x] = nil
  end
  if $map[y][x] == ?* then win end
  return $map[y][x] == ?# || $map[y][x] == ?|
end

def win
  exit
end

def visible?(p0, p1)
  [[0,1], [1,0]].each do |c|
    if p0[c[0]]<p1[c[0]] then
      p0[c[0]].upto(p1[c[0]]-1)
    else p0[c[0]].downto(p1[c[0]]+1)
    end
    .each do |c0|
      c1 =  (((p1[c[1]]-p0[c[1]])*(c0-p0[c[0]])).fdiv(p1[c[0]]-p0[c[0]])+p0[c[1]]) #no divide-by-zero problem because x1.upto(x2-1) won't run anything if x1==x2
      if [[c1.ceil, c0], [c1.floor, c0]].all? do |e|
        ($map[e[c[0]]][e[c[1]]] == ?# || $map[e[c[0]]][e[c[1]]] == ?|)
      end
      then
      return false
      end
    end
  end
  return true
end

def occupied?(x, y)
  return (not ($map[y][x] == nil))
end

def display()
  Termbox.tb_clear
  $map.each_index do |y|
    $map[y].each_index do |x|
      if not $map[y][x].nil? then
        if visible? [$mex, $mey], [x, y] then
          Termbox.tb_change_cell x, y, $map[y][x].ord, 4, 0
          $map[y][x].instance_variable_set(:@seen, true)
        elsif $map[y][x].instance_variable_get(:@seen) then
          Termbox.tb_change_cell x, y, $map[y][x].ord, 1, 0
        end
      end
    end
  end
  Termbox.tb_present
end

def main()
  display
  keyboard_controls
end

begin
  Termbox.tb_init
  loop do
    main
  end
ensure
  Termbox.tb_shutdown
end
