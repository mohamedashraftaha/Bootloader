 ;************************************** lba_2_chs.asm **************************************
 lba_2_chs:  ; Convert the value store in [lba_sector] to its equivelant CHS values and store them in [Cylinder],[Head], and [Sector]
              ; This function need to be written by you.

pusha ; push all registers on stack to store and save them
xor dx,dx ; Zero out dx; in division procedure in x86 -> dx always store the remainder, so we must zero it out
mov ax, [lba_sector] ; Move [lba_sector] to ax;; The quotient after division procedures
div word [spt] ; Divide AX by word[spt] -> DX = remainder, AX = quotient -> as mentioned above// 
inc dx ; // DX is the sector number within the track that we want to read from //we add to it 1 to get sector in the CHS format

mov [Sector], dx ; store dx (sector number in CHS format) into address [Sector] in memory

xor dx,dx ; Zero out dx same as the procedure above in the division functions
div word [hpc] ; we now take the quotient AX and divided it by word[hpc] //

mov [Cylinder], ax ;  After division AX will have the cylinder number and then we will store it into memory address[Cylinder]
mov [Head], dl ; and the remainder value dl will now have the value of head and then we will store the value in memory address[head]
popa ; Retrieve all values from the stack
ret ; will return to execute the next instruction after its call function