require 'termbox'

Termbox.initialize_library

begin
    Termbox.tb_init
    Termbox.tb_change_cell 0, 0, ?A.ord, 0, 0
    Termbox.tb_present
    sleep 2
ensure
    Termbox.tb_shutdown
end
