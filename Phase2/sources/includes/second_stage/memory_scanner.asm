%define MEM_REGIONS_SEGMENT         0x2000
%define PTR_MEM_REGIONS_COUNT       0x1000
%define PTR_MEM_REGIONS_TABLE       0x1018
%define MEM_MAGIC_NUMBER            0x0534D4150
    memory_scanner:
            pusha                                       ; Save all general purpose registers on the stack

            mov ax,MEM_REGIONS_SEGMENT ;set ax with the predefined value of MEM_REGIONS_SEGMENT in the above defined macro
            mov es,ax ; move ax to es
            xor ebx,ebx ; initialize ebx by zero
            mov [es:PTR_MEM_REGIONS_COUNT],word 0x0 ; initialize by zero to be used as a counter to count the memory regions which will be read
            mov di, PTR_MEM_REGIONS_TABLE ; move PTR_MEM_REGIONS_TABLE to di to store the page table in this register
            .memory_scanner_loop: ; label to loop on the memory regions to be read
            mov edx,MEM_MAGIC_NUMBER ; move MEM_MAGIC_NUMBER to edx
            mov word [es:di+20], 0x1 ; declaring the word with 0x1 function to be used interrupt 0x18
            mov eax, 0xE820 ; setting the memory scanner to be used in the mem scan function
            mov ecx,0x18 ;declaring the buffer of the memory to be used to  store memory data
            int 0x15 ; firing interrupt
            jc .memory_scan_failed ; a flag will be carried if error has occured and it will jump to the label
            cmp eax,MEM_MAGIC_NUMBER ; proceed if eax which is loaded in the above instruction is equal to MEM_MAGIC_NUMBER then proceed
            jnz .memory_scan_failed ; if something wrong occured in the previous instruction then jump to label and print label
            add di,0x18 ; Increment the counter to move to the next region in the disk
            inc word [es:PTR_MEM_REGIONS_COUNT] ; Increment the memory regions counter
            cmp ebx,0x0 ; if this is satisfied then we finished scanning all memory
            jne .memory_scanner_loop ; if we did not finish scanning then loop again
            jmp .finish_memory_scan ; this means that we successfuly finished
            .memory_scan_failed: ; label which means that something worng occured
            .finish_memory_scan: ; all processes is successfuly completed
            popa                                        ; Restore all general purpose registers from the stack
            ret   ; return to the main file

    print_memory_regions:
            pusha
            mov ax,MEM_REGIONS_SEGMENT                  ; Set ES to 0x0000
            mov es,ax
            xor edi,edi
            mov di,word [es:PTR_MEM_REGIONS_COUNT]
            call bios_print_hexa
            mov si,newline
            call bios_print
            mov ecx,[es:PTR_MEM_REGIONS_COUNT]
            mov si,0x1018
            .print_memory_regions_loop:
                mov edi,dword [es:si+4]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si]
                call bios_print_hexa
                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+12]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si+8]
                call bios_print_hexa

                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+16]
                call bios_print_hexa_with_prefix


                push si
                mov si,newline
                call bios_print
                pop si
                add si,0x18

                dec ecx
                cmp ecx,0x0
                jne .print_memory_regions_loop
            popa
            ret
