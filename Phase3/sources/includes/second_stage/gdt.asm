GDT64: ; global descriptor table // entries in table -> defines memory region // 8 byte entry
    ;;Each GDT entry has limit, Base, Access Byte, Flags



    .Null: equ $ - GDT64         ; The null descriptor// It is the first entry in the table-> everything is 0 in it -> unusable; yet it has to exist.
    ; This function need to be written by you.
        dw 0 ; Limit (low).
        dw 0 ; Base (low). // 31 - 16 bits 
        db 0 ; Base (middle) // 39 - 32 bits 
        db 0 ; Access byte.
        db 0 ; Flags - Limit(high).
        db 0 ; Base (high). // 63 - 56 bits 


    .Code: equ $ - GDT64         ; The Kernel code descriptor.
    ; This function need to be written by you.
        dw 0 ; Limit (low).
        dw 0 ; Base (low). // 31-16 bits
        db 0 ; Base (middle) // 39-32 bits
        db 10011000b ; Access byte: Pr,ring0,Ex .// first bit -> 1 == present// next two bits -> 00 == ring 0-> Kernel// next bit-> Ex-> 1 -> execute what the data in this area//next bit -> DC==1 -> direction grows downward(for the stack)// 
        db 00100000b ; Flags: L - Limit(high).
        db 0 ; Base (high). // 63- 56 bits

    .Data: equ $ - GDT64         ; The Kernel data descriptor.
    ; This function need to be written by you.
    
    dw 0 ; Limit (low)
    dw 0 ; Base (low). //31 -16 bits
    db 0 ; Base (middle) // 39- 32 bits
    db 10010011b ; Access byte: Pr,ring0,RW,Ac.// first bit -> 1 == present// next two bits -> 00 == ring 0-> Kernel// next bit-> Ex-> 1 -> execute what the data in this area//next bit -> DC==0 -> direction grows Upward(for the stack)// RW-> write bit in data segment -> data is writable// AC set automatically by CPU when the memory area is accessed
    db 00000000b ; Flags - Limit(high). // FLags are all zeros
    db 0 ; Base (high). //63-56 bits
    ALIGN 4
    dw 0 ; Padding to make the "address of the GDT" field aligned

    .Pointer:
    ; This function need to be written by you.
;//Creating a discriptor to store in it the address and size of GDT
;// Give this pointer to GDT to store it but this must be done before going to long mode
;// GDT must be loaded before going to longmode
;// because if we load into gdt the CS will be pointing in a wrong direction-> we cannot execute any instructions

    dw $ - GDT64 - 1 ; 16-bit Size (Limit) of GDT.
    dd GDT64 ; 32-bit Base Address of GDT. (CPU will zero extend to 64-bit)
