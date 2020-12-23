;*******************************************************************************************************************
%define CONFIG_ADDRESS  0xcf8
%define CONFIG_DATA     0xcfc

ata_device_msg db 'Found ATA Controller',13,10,0
pci_header times 512 db 0



struc PCI_CONF_SPACE 
.vendor_id          resw    1
.device_id          resw    1
.command            resw    1
.status             resw    1
.rev                resb    1
.prog_if            resb    1
.subclass           resb    1
.class              resb    1
.cache_line_size    resb    1
.latency            resb    1
.header_type        resb    1
.bist               resb    1
.bar0               resd    1
.bar1               resd    1
.bar2               resd    1
.bar3               resd    1
.bar4               resd    1
.bar5               resd    1
.reserved           resd    2
.int_line           resb    1
.int_pin            resb    1
.min_grant          resb    1
.max_latency        resb    1
.data               resb    192
endstruc

get_pci_device:
    ;Compose the Config Address Register (32-bis):
    ;  Bit 23-16 : bus (so we shift left 16 bits))
    ;  Bit 15-11 : device (so we shift left 11 bits))
    ;  Bit 10-8 : function (so we shift left 8 bits))
    ;  Bit 7-2 : so we clear the last two bytes by & 0xfc
    ;  Bit 31 : Enable bit, and to set it we | 0x80000000
    ;  ((bus << 16) | (device << 11) | (function << 8) | (offset & 0xfc) | ( 0x80000000))    
    ;; bus part
    xor rax,rax ;; initializing both registers by zero to perform future operations
    xor rbx,rbx ;; initialzing with zero to perform future operation
    mov bl,[bus] ;moving the bus number [addr] to the bl register
    shl bl,16 ;; shifiting by 16 for bus number 

    ;; device part
    or eax,ebx
    xor rbx,rbx ;; initializing by zero for future operations
    mov bl,[device] ;moving device number [addr] to the bl register
    shl bl, 11 ;; shifting by 11 bits to get the device number

    
    ;;function part 
    or eax,ebx
    xor rbx,rbx ;; initializing by zero for future operations
    mov bl, [function] ;; moving function number[addr] to bl register 
    shl bl, 8 ;; shifiting by 8 bits to get the function number 
    xor rbx,rbx ;; initializing register by zero for future operations
    or eax,ebx  


    or eax,0x80000000 ;; the enable bit 31
    xor rsi,rsi ; using it as an offset to jump from to another header

ret ;; returning to the location of the statement in the main file to execute and move to the next instruction
