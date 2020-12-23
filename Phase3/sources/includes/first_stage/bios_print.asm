;************************************** bios_print.asm **************************************
      bios_print:       ; A subroutine to print a string on the screen using the bios int 0x10.
                        ; Expects si to have the address of the string to be printed.
                        ; Will loop on the string characters, printing one by one.
                        ; Will Stop when encountering character 0.
          pusha ; push all registers on the stack for further operations
         .print_loop: ;label of print_loop which loops on all bytes in the string to be loaded and displayed on screen and it ends when the null terminator character appears
          xor ax,ax ; ;initializing ax register with zero
         lodsb ;loading the current byte of the string into the source register (si) and copy into al(register) +incrementing
        or al, al ; checking if the al contains zero (this means that we reached the end of the string (null terminator))
        jz .done ; if al(register) contains zero then jump to label (.done) which means that we finished looping on the string. In the label, all registers are popped and we return to the main file
        mov ah, 0x0E ; loading the current character into the ah
          int 0x10 ; interrupt to print the current character on the screen
        jmp .print_loop ; jump again to the beginning of the loop until the whole string is fetched
          .done: ; done (label) which contains :
            popa ; popping al registers on the stack
              ret ; returning to the main file of the first stage and then jump to the next instruction in the main file to be executed.
