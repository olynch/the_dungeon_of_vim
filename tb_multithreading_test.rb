require 'termbox'

#Small example that shows multithreading breaks ruby termbox
#if the display thread executes AFTER the tb_poll_event thread, the call to tb_poll_event freezes Termbox, not allowing the display to happen
#if, however, we switch the sleep statements and the display thread executes first, there is no problem.
#This shows that the problem is indeed with the interaction between these two functions
#Press any key to exit program

Termbox.initialize_library

begin
  Termbox.tb_init
  Thread.new { #Thread #1, polls events
    #sleep 1 #switch which sleep statement is commented out for reversal of behaviour
    Termbox.tb_poll_event(Termbox::Event.new)
    exit #press any key to get past tb_poll_event and exit program
  }
  Thread.new { #Thread #2, displays an "A"
    sleep 1 #switch which sleep statement is commented out for reversal of behaviour
    Termbox.tb_clear
    Termbox.tb_change_cell 1,1, ?A.ord, 0, 0
    Termbox.tb_present
  }
  loop {} #loop so the program doesn't exit (keep threads going)
ensure
  Termbox.tb_shutdown
end
