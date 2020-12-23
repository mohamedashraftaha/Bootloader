;************************************** get_key_stroke.asm **************************************
        get_key_stroke: ; A routine to print a confirmation message and wait for key press to jump to second boot stage
        pusha ; push all registers on the stack for further operations
         mov ah,0x0 ; function 0x0 for INT 0x16 which gets keyboard input
         int 0x16 ; interrupt 0x16 which interrupts the processor by the keyboard
         popa ; pop all registers from the stack
         ret ; return to the main file of the first stage and jump to the next instruction to be executed in the main file.

         
