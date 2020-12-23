        check_long_mode:
            pusha                           ; Save all general purpose registers on the stack
            call check_cpuid_support        ; Check if cpuid instruction is supported by the CPU
            call check_long_mode_with_cpuid ; check long mode using cpuid
            popa                            ; Restore all general purpose registers from the stack
            ret

        check_cpuid_support:
            pusha               ; Save all general purpose registers on the stack

                  ; This function need to be written by you.
                pushfd                                      ; Push eflags for restoring them at the end of the subroutine  
                pushfd                                      ; Push eflags again to use them for comparison
                pushfd                                      ;Copy flags to eax
                pop eax                                     ;pop flags to register eax
                xor eax, 0x0200000                          ;zero out all other bits and Flip bit 21
                push eax                                    ;Copy value of eax to the eflags after modfying bit 21
                popfd                                       ;set flags to same values but with bit 21 flipped
                pushfd                                      ; Copy eflags to eax
                pop eax                                     ;if bit 21 can be can be changed in the eax it will show in this step
                pop ecx                                     ;Copy original eflags to ecx (second pushfd above)
 ; if eax and ecx are the same that means that bit 21 cannot be modified and cpuid is not supported
                xor eax,ecx                                 ;This means that xoring registers will always produce 1 if 21 bit of both is diffrent then(cpuid is supported );else 0 if it is not the same(cpuid is not supported)
                and eax,0x0200000                           ;Now we know if cpuid is supported or not ;now Zero out all bits except bit 21

                cmp eax,0x0                                 ; If eax equal zero this means that bit 21 was not modified in eflags so cpuid is not supported
                jne .cpuid_supported                        ;Jump to .cpuid_supported if cpuid is supported
                mov si,cpuid_not_supported                  ;Else print error message and hang as we cannot proceed
                call bios_print                             ;call bios_print function
                jmp hang                                    

                .cpuid_supported:
                    mov si,cpuid_supported                  ;Print a message indicating that cpuid is supported
                    call bios_print                         ;call function bios_print
                    popfd                                   ;Restore eflags (First pushfd)
            popa                ; Restore all general purpose registers from the stack
            ret                 ;return to function caller

        check_long_mode_with_cpuid:
            pusha                                   ; Save all general purpose registers on the stack

                ; This function need to be written by you.
                    mov eax,0x80000000                      ; to check long mode now that I know cpuid is supportded cpuid function 0x80000000 returns the maximum function value that can be used by cpuid to check if 0x80000001 is supported or not
                    cpuid                                   ;call cpuid (with function ID in eax, returns highest calling parameter in eax)
                    cmp eax,0x80000001                      ;If the largest function number is less than 0x80000001 then it is not supported
                    jl .long_mode_not_supported             ; Error and hang
                    mov eax,0x80000001                      ;Else invoke cpuid function 0x80000001 to get the processor extended features bits (EDX).
                    cpuid                                   ;call cpuid (with fuunction ID in eax, this stores processor extended features bits in ecx and edx)
                    and edx,0x20000000                      ; Mask out all bits in edx(it's the extended feature register) except bit # 29 to check whther long mode is supoorted ir not 
                    cmp edx,0                               ; if edx is zero then bit 29 wasnt modified and long mode is not supported
                    je .long_mode_not_supported             ; If Long mode is not supported then we need to print a message and stop
                    mov si,long_mode_supported_msg          ;Else print a message indicating the long mode is supported
                    call bios_print                         
                    jmp .exit_check_long_mode_with_cpuid    ; Skip over the long mode not supported section
                
                .long_mode_not_supported: 
                    mov si,long_mode_not_supported_msg      ;If we are here then long mode is not supported
                    call bios_print                         ;Print an error message and jump to hang
                    jmp hang                                

                .exit_check_long_mode_with_cpuid: 
            popa                                ; Restore all general purpose registers from the stack
            ret                                 ;return to function caller