require 'termbox'

Termbox.initialize_library

#class Map
    #def initialize(map_file)
#end

$map = [[?#, ?#, ?#, ?#, ?#,  0,  0,  0,  0,  0],
        [?#,  0,  0,  0, ?#, ?#, ?#, ?#, ?#,  0],
        [?#,  0,  0,  0,  0,  0,  0,  0, ?#,  0],
        [?#,  0, ?@,  0,  0,  0, ?#, ?#, ?#,  0],
        [?#,  0,  0,  0, ?#, ?#, ?#,  0,  0,  0],
        [?#, ?#, ?#, ?#, ?#,  0,  0,  0,  0,  0]]


$mey = $map.index { |r| $mex = r.index { |x| x == ?@ } }

def keyboard_controls()
    ev = Termbox::Event.new
    if Termbox.tb_poll_event(ev) >= 0 && ev[:type] == 1 then
        case ev[:key]
        when 0x1B
            exit
        when 0xFFFF-18
            if not occupied? $mex, $mey-1 then
                $map[$mey][$mex]=0
                $mey-=1
                $map[$mey][$mex]=?@
            end
        when 0xFFFF-19
            if not occupied? $mex, $mey+1 then
                $map[$mey][$mex]=0
                $mey+=1
                $map[$mey][$mex]=?@
            end
        when 0xFFFF-20
            if not occupied? $mex-1, $mey then
                $map[$mey][$mex]=0
                $mex-=1
                $map[$mey][$mex]=?@
            end
        when 0xFFFF-21
            if not occupied? $mex+1, $mey then
                $map[$mey][$mex]=0
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

def occupied?(x, y)
    return (not ($map[y][x] == 0))
end

def display()
    Termbox.tb_clear
    $map.each_index do |y|
        $map[y].each_index do |x|
            Termbox.tb_change_cell x, y, $map[y][x].ord, 0, 0
        end
    end
    Termbox.tb_change_cell $mex, $mey, ?@.ord, 0, 0
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
