%define PIT_DATA0       0x40
%define PIT_DATA1       0x41
%define PIT_DATA2       0x42
%define PIT_COMMAND     0x43
;; the default function printed the counter at each interrupt → 1234567.....
;; but what we need to do is to print the pit counter every 10000 interrupts
interrupt_counter dq 1000  ;; this is a counter to check if we reached the 10000 interrupts or not to print on screen
pit_counter dq    0x0               ; Used to print on screen every time an interrupt occur and then increment it

handle_pit:
      pushaq
      
            ;;BASE CASE
            cmp QWORD[interrupt_counter], 1000 ; check if we reached the 10000 interrupts
            je _int_cntr_equ_1000;; if we reached the 10000 interrupts (the counter reached 1000 so we print on screen)
            ;;else
            cmp QWORD[interrupt_counter],0 ;; check if we reached to 0 
            jg _continue   ;; if we still didnt finish the 1000 iterations (interrupts)→ dont print that on screen and update the counters
            je _restart   ;; but if we finished the 1000 iteration we will move again into interrupt counter 1000 and start iterating once more
            
            _int_cntr_equ_1000:
            _print_pit_cntr:
            mov rdi,[pit_counter]         ; Value to be printed in hexa
            push qword [start_location]
            mov qword [start_location],0 ;; Screen location for printing
            mov rsi,0x1
            call video_print_hexa          ; Print pit_counter in hexa
            ;mov rsi,newline
            ;call video_print
            pop qword [start_location]

            _continue:
            _update_counters:
            dec QWORD[interrupt_counter] ;; decrementing the counter untill reaching 0
            inc qword [pit_counter]       ; Increment pit_counter
      popaq
      ret
      _restart: ;; restarting the procedure again
      mov QWORD[interrupt_counter],1000
      jmp _int_cntr_equ_1000 ;; now that we restarted the procedure and it is 10000 again we should go continue printing 



configure_pit:
    pushaq
      ; This function need to be written by you.
      mov rdi,32 ; PIT is connected to IRQ0 → Interrupt 32
      
      ;;when an interrupt happens-> the handle_pit will handle the interrupt
      mov rsi, handle_pit ; move into rsi the address of the handler
      mov al,00110110b ; configuring channel 0 → set PIT Command Register 00 → Channel 0, 11 → Write lo,hi bytes, 011 → Mode 3, → Bin
      call register_idt_handler ; store the address of the handler pit in location number 32
      out PIT_COMMAND,al ; write command port → pit command
      ;; after this part we need to write two values to the data port so that we set up the values 
      xor rdx,rdx ; Zero out register RDX for division// as it is always used in the division procedure// we div whatever in rax and rdx together
      mov rcx,50 ; mov 50 in rcx → divident // we need to divide the frequency by 50 so that it fires 50 times per second
      mov rax,1193180 ; 1.193180 MHz
      div rcx ; Calculate divider → 11931280/50 Divide RDX:RAX/RCX, RDX contains the remainder → after the operation
      out PIT_DATA0,al ; Write low byte to channel 0 data port // first 8 bits
      mov al,ah ; Copy high byte to AL ;; no need
      out PIT_DATA0,al ; Write high byte to channel 0 data port
    popaq
    ret