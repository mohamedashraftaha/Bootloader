;************************************** read_disk_sectors.asm **************************************
 read_disk_sectors: ; This function will read a number of 512-sectors stored in DI
 ; The sectors should be loaded at the address starting at [disk_read_segment:disk_read_offset]
 pusha ; Save all general purpose registers on the stack in 16-bit mode
 add di,[lba_sector] ; di the number of sectors we want to read, lba_sector holds the starting sector, adding them puts us at the last sector to read
 mov ax,[disk_read_segment] ; disk_read_segment holds the segment number we want to reach  
 mov es,ax ; We cannot set es directly, so we load it from ax
 add bx,[disk_read_offset] ; set bx to the offset the intrupt 13/fn 2 condition of segment reads from location es:bx to traverse the sectors
 mov dl,[boot_drive] ; move into dl the device number we want to read from
 .read_sector_loop:
 call lba_2_chs ; First we call lba_2_chs to convert the lbs value stored in [lba_sector] to CHS.
 mov ah, 0x2 ; Set Interrupt 13 to function 0x2 
 mov al,0x1 ; 0x1 or 1 sector only to we want to read
 mov cx,[Cylinder] ; Store Cylinder into CX
 shl cx,0x8 ; Shift the value of CX 8 bits to the left
 or cx,[Sector] ; Store Sector into CX first 6 bits
 mov dh,[Head] ; Store the head into dh
 int 0x13 ; Read in the location es:bx set above
 jc .read_disk_error ; If carry flag is 1 then something wrong happened so jump to .read_disk_error
 mov si,dot ; Else print a '.' indicating successful sector read
 call bios_print
 inc word [lba_sector] ; Advance to the next sector
 add bx,0x200 ; Advance to the next memory location add 512 bytes
 cmp word[lba_sector],di ; if di==lba_sector then we are done reading the sectors we want
 jl .read_sector_loop ; loop till I read all the sector
 jmp .finish ; If we are here, then nothing wrong happened and we should skip printing an error
.read_disk_error:
mov si,disk_error_msg ; If we are here then something wrong like (reading from a not the same segment happened and we need to print an error message
 call bios_print
 jmp hang
.finish:
 popa ; Restore all general purpose registers from the stack
 ret