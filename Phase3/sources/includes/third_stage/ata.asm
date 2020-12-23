; The Command Register and trhe BASE I/O ports can be retrieved from the PCI BARs, but they are kind of standard and we will define them here for better code presentability
; When we write it is considered CR, and when we read what is returned is the AS Register
%define ATA_PRIMARY_CR_AS        0x3F6 ; ATA Primary Control Register/Alternate Status Port
%define ATA_SECONDARY_CR_AS      0x376 ; ATA Secondary Control Register/Alternate Status Port

%define ATA_PRIMARY_BASE_IO          0x1F0 ; ATA Primary Base I/O Port, up to 8 ports available to 0x1F7
%define ATA_SECONDARY_BASE_IO          0x170 ; ATA Primary Base I/O Port, up to 8 ports available to 0x177

%define ATA_MASTER              0x0     ; Mastrer Drive Indicator
%define ATA_SLAVE               0x1     ; SLave Drive Indicator

%define ATA_MASTER_DRV_SELECTOR    0xA0     ; Sent to ATA_REG_HDDEVSEL for master
%define ATA_SLAVE_DRV_SELECTOR     0xB0     ; sent to ATA_REG_HDDEVSEL for slave


; Commands to issue to the controller channels
%define ATA_CMD_READ_PIO          0x20      ; PIO LBA-28 Read
%define ATA_CMD_READ_PIO_EXT      0x24      ; PIO LBA-48 Read
%define ATA_CMD_READ_DMA          0xC8      ; DMA LBA-28 Read
%define ATA_CMD_READ_DMA_EXT      0x25      ; DMA LBA-48 Read
%define ATA_CMD_WRITE_PIO         0x30      ; PIO LBA-28 Write
%define ATA_CMD_WRITE_PIO_EXT     0x34      ; PIO LBA-48 Write
%define ATA_CMD_WRITE_DMA         0xCA      ; DMA LBA-28 Write
%define ATA_CMD_WRITE_DMA_EXT     0x35      ; DMA LBA-48 Write
%define ATA_CMD_IDENTIFY          0xEC      ; Identify Command

; Different Status values where each bit represents a status
%define ATA_SR_BSY 0x80             ; 10000000b     Busy
%define ATA_SR_DRDY 0x40            ; 01000000b     Drive Ready
%define ATA_SR_DF 0x20              ; 00100000b     Drive Fault
%define ATA_SR_DSC 0x10             ; 00010000b     Overlapped mde
%define ATA_SR_DRQ 0x08             ; 00001000b     Set when the drive has PIO data to transfer
%define ATA_SR_CORR 0x04            ; 00000100b     Corrected Data; always set to zero
%define ATA_SR_IDX 0x02             ; 00000010b     Index Status always set to Zero
%define ATA_SR_ERR 0x01             ; 00000001b     Error


; Ports offsets that can be used relative to the I/O base ports above.
; The use of the offset is defined by the ATA data sheet specifications.
%define ATA_REG_DATA       0x00
%define ATA_REG_ERROR      0x01
%define ATA_REG_FEATURES   0x01
%define ATA_REG_SECCOUNT0  0x02     ; Used to send the number
 ;of sectors to read, max 256
%define ATA_REG_LBA0       0x03     ; LBA0,1,2 are used to store the address of the first sector (24-bits)
%define ATA_REG_LBA1       0x04     ; Incase of LBA-28 the remaining 4 bits are sent as the higher 4 bits of
%define ATA_REG_LBA2       0x05     ; ATA_REG_HDDEVSEL when selecting the drive
%define ATA_REG_SECCOUNT1  0x02     ; Used for LBA-48 which allows 16 bit for the number of sector to be read, max 65536 
%define ATA_REG_LBA3       0x03     ; The rmaining 20-bit to acheive LBA-48 and nothing is written to  ATA_REG_HDDEVSEL
%define ATA_REG_LBA4       0x04
%define ATA_REG_LBA5       0x05
%define ATA_REG_HDDEVSEL   0x06     ; The register for selecting the drive, master of slave
%define ATA_REG_COMMAND    0x07     ; This register for sending the command to be performed after filling up the rest of the registers
%define ATA_REG_STATUS     0x07     ; This register is used to read the status of the channel

ata_pci_header times 1024 db 0  ; A memroy space to store ATA Controller PCI Header (4*256)
; Indexed values
ata_control_ports dw ATA_PRIMARY_CR_AS,ATA_SECONDARY_CR_AS,0
ata_base_io_ports dw ATA_PRIMARY_BASE_IO,ATA_SECONDARY_BASE_IO,0
ata_slave_identifier db ATA_MASTER,ATA_SLAVE,0
ata_drv_selector db ATA_MASTER_DRV_SELECTOR,ATA_SLAVE_DRV_SELECTOR,0

ata_error_msg       db "Error Identifying Drive",13,10,0
ata_identify_msg    db "Found Drive",0
ata_identify_buffer times 2048 db 0  ; A memroy space to store the 4 ATA devices identify details (4*512)
ata_identify_buffer_index dw 0x0
ata_channel db 0
ata_slave db 0  
lba_48_supported db 'LBA-48 Supported',0
align 4


struc ATA_IDENTIFY_DEV_DUMP                     ; Starts at
.device_type                resw              1
.cylinders                  resw              1 ; 1
.gap0                       resw              1 ; 2
.heads                      resw              1 ; 3
.gap1                       resw              2 ; 4
.sectors                    resw              1 ; 6
.gap2                       resw              3 ; 7
.serial                     resw              10 ; 10
.gap3                       resw              3  ; 20
.fw_version                 resw              4  ; 23
.model_number               resw              20 ; 27
.gap4                       resw              2  ; 47
.capabilities               resw              1  ; 49       Bit-9 set for LBA Support, Bit-8 for DMA Support
.gap5                       resw              3  ; 50
.avail_bf                   resw              1  ; 53
.current_cyl                resw              1  ; 54
.current_hdr                resw              1  ; 55
.current_sec                resw              1  ; 56
.total_sec_obs              resd              1  ; 57
.gap6                       resw              1  ; 59
.total_sec                  resd              1  ; 60       Number of sectors when in LBA-28 mode
.gap7                       resw              1  ; 62
.dma_mode                   resw              1  ; 63
.gap8                       resw              16 ; 64
.major_ver_num              resw              1  ; 80
.minor_ver_num              resw              1  ; 81
.command_set1               resw              1  ; 82
.command_set2               resw              1  ; 83
.command_set3               resw              1  ; 84
.command_set4               resw              1  ; 85
.command_set5               resw              1  ; 86       Bit-10 is set if LBA-48 is supported
.command_set6               resw              1  ; 87
.ultra_dma_reporting        resw              1  ; 88
.gap9                       resw              11 ; 89
.lba_48_sectors             resq              1  ; 100      Number of sectors when in LBA-48 mode
.gap10                      resw              23 ; 104
.rem_media_status_notif     resw              1  ; 127
.gap11                      resw              48 ; 128
.curret_media_serial_number resw              1  ; 176
.gap12                       resw             78 ; 177
.integrity_word             resw              1  ; 255      Checksum
endstruc


ata_copy_pci_header: 


            pushaq ;; pushing all registers into the stack

    mov rdi,ata_pci_header ;; moving ata pci header into rdi 
    mov rsi,pci_header ;; moving pci header into rsi
    mov rcx, 0x20 ;  set rep counter to 0x20 -> 32 * 8 = 256
    xor rax, rax ; Zero out eax
    cld ; clear direction flag; decrement rcx
    rep stosq ; Store EAX (4 bytes) at address RDI    
             popaq ;; pop all registers from stack 
    ret ;; return to the main file to execute next statement in the main file

select_ata_disk:              ; rdi = channel, rsi = master/slave
            pushaq ;; pushing all registers into the stack  
    xor rax,rax ; initializing rax by zero for future operations 
    mov dx,[ata_base_io_ports+rdi] ; Fetch channel corresponding base I/O port
    add dx,ATA_REG_HDDEVSEL ; Add port offset for selecting the drive
    mov al,byte [ata_drv_selector+rsi] ; Fetch the corresponding drive value, master/slave
    out dx,al ; using "OUT" to write on the I/O port   
             popaq ; pop all registers from stack 
    ret ;; return to the main file to execute the next instruction

ata_print_size:   ;; 
             pushaq
    mov byte [ata_identify_buffer+39],0x0 ; Setting a null character after serial
    mov rsi, ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.serial ; Printing a null character after serial
    call video_print ;; call video print routine to print 
    mov rsi,comma ;; move comma label to rsi register
    call video_print ;; call video print routine to print on screen
    
    mov byte [ata_identify_buffer+50],0x0 ;; assigning 0 hexa into ata identify buffer plus the offset ;;?
    mov rsi, ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.fw_version ; Printing a null character after serial
   
    call video_print ;; calling video print routine to print on screen 
    mov rsi,comma ;; moving comma label to rsi
    call video_print ;; calling video print routine to print on screen 
   
    xor rdi,rdi ;; initializing rdi register with zero
    mov rdi, qword [ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.lba_48_sectors] ; Printing number of LBA Sectors
    call video_print_hexa ;; calling bios print hexa to print 
    mov ax, 0000010000000000b ;; moving this value in binary to ax ;;?
    and ax,word [ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.command_set5] ; Checking LBA-48 bit
    cmp ax,0x0 ;; comparing the value in ax register with 0x0 hexa 
    je .out ; jump to label .out if the previous statement is sucssesfully satisfied
    
    mov rsi,comma ;; moving comma variable into rsi
    call video_print ;; calling video print routine to print on screen 
    mov rsi,lba_48_supported ;; moving the string of lba 48 supported into rsi register
    call video_print ;; calling video print routine to print on screen 
        .out: ;; .out label to jump to if ax is == to 0x0
    mov rsi,newline ;; moving new line string to rsi  to print new line 
    call video_print  ;; calling video print to print on screen             
popaq ;; popping all registers from stack 
ret ;; returning to the main file to jump to the next instruction to execute 


ata_identify_disk:              ; rdi = channel, rsi = master/slave
             pushaq ;; pushing all registers into the stack
        
xor rax,00000000b ; refresh channel of the disk
 mov dx,[ata_control_ports+rdi] ; move ata control ports plus the rdi which contains the channel of disk into reg dx
 out dx,al ; sending to the I/O ports
 
 call select_ata_disk ; Select Disk to send the identify packet

 xor rax,rax ; Zero out RAX

 mov dx,[ata_base_io_ports+rdi] ; Send out zero to sector count, lba0, lba1, and lba2
 add dx,ATA_REG_SECCOUNT0 ; adding dx to ATA reg seccount which contains number of sectors on disk 256
 out dx,al ;; sending dx to I/O ports
 mov dx,[ata_base_io_ports+rdi] ;; moving [ata base io ports plus the channel of the disk] to the dx register 
 add dx,ATA_REG_LBA0  ; stroing the value of dx in [ATA reg lba0] where the first sector is stored
 out dx,al ; writing to the I/O port
 mov dx,[ata_base_io_ports+rdi] ; moving the [ata base io ports plus the rdi ] to the dx register 
 add dx,ATA_REG_LBA1 ; storing dx into [ata reg lba1]
 out dx,al ; writing to the I/O port
 mov dx,[ata_base_io_ports+rdi] ;; moving [ata base io ports plus the rdi ] into register dx
 add dx,ATA_REG_LBA2 ; storing [ata reg lba2] into dx
 out dx,al; writing into the I/O port
 mov dx,[ata_base_io_ports+rdi] ; Send Identify command
 add dx,ATA_REG_COMMAND ;; storing [ata reg command] into register dx
 mov al,ATA_CMD_IDENTIFY ; moving [ata cmd identify] into al
 out dx,al ; writing into I/O ports
 mov dx,[ata_base_io_ports+rdi] ; Read the status for the first time
 add dx,ATA_REG_STATUS ;; moving the status into dx register
 in al, dx ; reading from I/O port
 cmp al, 0x2 ; comparing al with 0x2 hexa
 jl .error ; Error if status is less than 2   

 .check_ready: ; A loop that checks status has an error or PIO Ready
 mov dx,[ata_base_io_ports+rdi] ;; moving [ata base io ports plus the channel] into dx
 add dx,ATA_REG_STATUS ; storing the status of ata into dx
 in al, dx ; reading from I/O port
 xor rcx,rcx ; initializing rcx register with zero
 mov cl,ATA_SR_ERR ;; moving string [ata sr err] to print if an error occured
 and cl,al ;; anding cl and al register
 cmp cl,ATA_SR_ERR ;; comparing [ata sr error] with cl
 je .error ;; jump to error label if cl and [ata sr err] are equal
 mov cl,ATA_SR_DRQ ;moving [ata sr drq] to cl
 and cl,al ; anding cl and al register
 cmp cl,ATA_SR_DRQ ; comparing [ata sr drq] with cl
 jne .check_ready  ; jump to check_ready label if the above instruction is not equal

 jmp .ready ; jump to ready label
 .error: ; Print error message and exit
 mov rsi,ata_error_msg ; moving the string of [ata error msg] into rsi register
 call video_print ;; call video print routine to display on screen
 jmp .out ; jump to out label
 .ready: ; Read from base port 256 words ATA Identify Configuration Data →
 mov rsi,ata_identify_msg ;; moving [ata identify msg] to rsi register
 call video_print ; call video print to print on screen
 mov rdx,[ata_base_io_ports+rdi] ;;move [ata base io ports plus the channel] to rdx register
 mov si,word [ata_identify_buffer_index] ;; move [ata identity buffer index] into si register
 add rdi,ata_identify_buffer ;; adding the buffer into rdi
 mov rcx, 256 ;; moving 256 into rcx (256 because the size of header)
 xor rbx,rbx ;; initializing rbx by zero
 rep insw ; repeat input from port to string 
 add word [ata_identify_buffer_index],512 ;; adding 256 to [ata identify buffer index]
 mov rsi,comma
 call video_print
 call ata_print_size;; calling [ata print info]
 .out: ;;output label
              popaq ;; pop all registers from the stack
    ret ;; return to main file to execute next instruction 

read_disk_sectors:
 pushaq
    xor rdi,rdi;; making sure that the register rdi is zero
    xor rsi,rsi ;; making sure that the register rsi is zero
    xor rax,rax ;; making sure that the reguster rax is zero
    xor rbx,rbx ;; making sure that the register rbx is zero
    xor r8,r8;; making sure it is zero
    mov r8,[ATA_REG_COMMAND];; moving the command register into r8
    xor QWORD[ATA_REG_COMMAND],0x2 ;; disabling interrupts by writing 0x2 to the command register 
    call ata_identify_disk ;; identifying the disk..

    ;checking if supported
    ;; same as we did in ata_print_size
    mov rdi, QWORD[ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.lba_48_sectors] ;; moving the number of sectors in the disk in the register rdi to check if supported
    push rdi ;; saving its value
    mov ax, 0000010000000000b                                                   ;To check if it is supported or not, we wrote the 10th bit as 1
    and ax, WORD[ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.command_set5];; command set 5 is responsible for checking if lba 48 is supported so when anding the 10th bit with it, if the result of the anding is one, so it is supported, else it is not supported
    cmp ax,0x0;comparing the result of the anding with 0, if it is 0 → lba 48 notsupported, if it is 1 → lba 48 supported
    je _LBA48_NotSupported
    _LBA48_NotSupported:
    ;xor rax,rax ;; making sure it is zero for reuse
    ;xor rdi,rdi;; making sure it is zero for reuse

    ;mov rax, QWORD[ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.lba_48_sectors] ;; number of sectors in the disk into rax
    call select_ata_disk;; selecting the target
    in al,dx ;; extratct the 8 first bits and put them into reg al
    shr al,4 ;;writing the left most 4 bits of the sector 
    mov dx,[ata_base_io_ports+rdi] ; Fetch channel corresponding base I/O port
    add dx,ATA_REG_HDDEVSEL ; Add port offset for selecting the drive
    mov al,byte [ata_drv_selector+rsi] ; Fetch the corresponding drive value, master/slave
    out dx,al ; using "OUT" to write on the I/O port   
    ;; in these steps we did this instruction in the slides "write the left most 4 bits of the sector address to the lower 4 bits of the drive select register"

    ;; First→ writing the first 8 bits of the sector count to SECCOUNT1
    ;; knowing from  the line "in al,dx" we know that dx has the 8 first bits
    ;;; adding the first 8 bits of the sector count to SECCOUNT1
    add dx, ATA_REG_SECCOUNT1 
    mov rax,QWORD[ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.lba_48_sectors]
    shr rax, 56; getting the upper 8 bits 64-8=56
    out dx,al;; put those first 8 bits in the dx which contains ATA_REG_SECCOUNT1
    ;; now we need to do the following write the upper 20 bits of the addr to lba3 and lba4 and lba5
    shr rax,44;; getting the upper 20 bits 64-44=20
    mov dx,[ata_base_io_ports+rdi]  ;the first part of the 20 bits
    add dx,ATA_REG_LBA3
    shl rax,60                      ;To get last 4 bits for lba3
    and rax,0x3C;;60                      ;to make sure we only have the 4 bits
    out dx,al;; writing 8 bits to ATA_REG_LBA3
    
    mov dx,[ata_base_io_ports+rdi]  ;for the second 8 bits
    add dx,ATA_REG_LBA4
    shl rax,52                      ;To get middle 8 bits for lba4
    and rax,0x38;56                      ;To keep the only 8 bits
    out dx,al;; writing 8 bits to ATA_REG_LBA4
    
    mov dx,[ata_base_io_ports+rdi]  ;For 3rd 8 bits
    add dx,ATA_REG_LBA5
    shr rax,12   
    and rax,0xC;12                      ;To keep the only 8 bits
    out dx,al;; writing 8 bits to ATA_REG_LBA5
    out dx,al




 popaq
 ret
