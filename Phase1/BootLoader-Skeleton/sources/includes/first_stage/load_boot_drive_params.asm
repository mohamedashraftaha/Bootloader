;************************************** load_boot_drive_params.asm **************************************
      load_boot_drive_params: ; A subroutine to read the [boot_drive] parameters and update [hpc] and [spt]
            ; This function need to be written by you.
pusha ; push all registers on stack to store and save them
xor di,di ; to zero di out ***1
mov es,di  ;; ES:DI must be 0x0000:0x0000 to overcome some buggy BIOSes **2 cont'd
mov ah,0x8 ; function 8 which fetches the parameter, before any interrupt ah should have the function number
mov dl,[boot_drive] ; move the device we want to detect which is stored in [boot drive] into register dl
int 0x13 ; Interrupt 0x13
inc dh ; dh should have the index of the last head; Since, heads begin from zero , we incremented by 1 to get the number of heads

;;Storing this value -> dh (Number of head/cylinder) in hpc which is defined as word despite the fact that this value is byte; 
mov word [hpc],0x0 ; Zero out [hpc] by moving constant 0 in it
mov [hpc+1],dh ; because we want to store in the second byte of [hpc](lower byte)// We dont want it to be stored in the whole word, because if we stored in the word it will be stored in reverse (Big endien)

; We are defining [hpc] as a word to ease calculating the CHS from LBS

and cx,0000000000111111b ; // We want to get the number of sectors per track which is stored in the first 6 bits of CX and it will give us the actual number of sectors as sectors are base 1// Number of Cylinders in the other 10 bits (but we dont need it)
mov word [spt],cx ; store the number of sector per track which is in CX into [spt]Store the Sector value into [spt]
popa ; retrieve all registers from the stack
