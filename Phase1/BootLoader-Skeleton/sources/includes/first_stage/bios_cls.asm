;************************************** bios_cls.asm **************************************
      bios_cls:   ;A routine to initialize video mode 80x25 which also clears the screen
      pusha ;pushes all registers on stack for further operations reserved macro in x86 (16-bit mode only)
       mov ah,0x0 ;sets video mode (function number before issuing an interrupt)
        mov al,0x3 ;sets color mode of text which will be displayed on screen (80x25 screen dimensions and 16 colors)
        int 0x10  ;interrupt 10 which communicates with the video card to display on the screen
        popa ;pop all registers on the stack
        ret ; return to the main file of the the first stage and then jump to the next instruction in the main file.
