require 'termbox'

Termbox.initialize_library

#class Dungeon
    #def self.parse(fn)
        #File.open(fn, ?r) do |f|
            #return f.each_line.map do |ln|
                #ln.each_char.map do |c|
                    #case c
                    #when ?#
                        #?#
                    #else
                        #nil
                    #end
                #end
            #end
        #end
    #end
    #def each(&block)
        #@grid.each do |row|
            #row.each do |thing|
                #yield thing unless thing.nil?
            #end
        #end
    #end
    #def initialize(li=[])
        #@grid = li
        #@gridy = @grid.length
        #@gridx = @grid[0].length
    #end
    #def [](y, x)
        #if x < 0 || y < 0 || y >= @grid.length || x >= @grid[0].length || @grid[y][x].nil? then
            #return nil
        #else
            #return @grid[y][x]
        #end
    #end
    #def occupied?(y, x)
        #return (not self[y,x].nil?)
    #end
#end

#$dngn = Dungeon.new(Dungeon.parse("dungeon.txt"))

$map = [[?#, ?#, ?#, ?#, ?#,  0,  0,  0,  0,  0],
        [?#,  0,  0,  0, ?#, ?#, ?#, ?#, ?#,  0],
        [?#,  0,  0,  0,  0,  0,  0,  0, ?#,  0],
        [?#,  0, ?@,  0,  0,  0, ?#, ?#, ?#,  0],
        [?#,  0,  0,  0, ?#, ?#, ?#,  0,  0,  0],
        [?#, ?#, ?#, ?#, ?#,  0,  0,  0,  0,  0]]


$mey = $map.index { |r| $mex = r.index { |x| x == ?@ } }

def parse_dun(fn)
    File.open(fn, ?r) do |f|
        return f.each_line.map do |ln|
            ln.each_char.map do |c|
                case c
                when ?#
                    ?#
                when ?@
                    ?@
                when ?k
                    ?k
                when ?|
                    ?|
                when ?*
                    ?*
                else
                    nil
                end
            end
        end
    end
end

$map = parse_dun("dungeon.txt")


$mey = $map.index { |r| $mex = r.index { |x| x == ?@ } }
$havekey = false

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
    end
end

def collision?(x, y)
    if $map[y][x] == ?k then $havekey = true end
    if $map[y][x] == ?* then win end
    return ($map[y][x] == ?#) || ($map[y][x] == ?| && $havekey==false)
end

def win
    exit
end

def occupied?(x, y)
    return (not ($map[y][x] == nil))
end

def display()
    Termbox.tb_clear
    $map.each_index do |y|
        $map[y].each_index do |x|
            if not $map[y][x].nil? then
                Termbox.tb_change_cell x, y, $map[y][x].ord, 0, 0
            end
        end
    end
    #Termbox.tb_change_cell $mex, $mey, ?@.ord, 0, 0
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
    Termbox.tb_present
    sleep 2
ensure
    Termbox.tb_shutdown
end
