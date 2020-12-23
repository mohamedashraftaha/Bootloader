            check_a20_gate:
    pusha                                   ; push all register on the stack to store and save their values

            ; This function need to be written by you.
        .check_gate:
            mov ax,0x2402                          ;load 0x2402 to ax (function number to check a20 gate when int 0x15 is issued)/ functions of the keyboard are stored in ax
            int 0x15                                ;issue bios interrupt on function in ax 0x2402
            jc .error                               ;jump error if carry flag is set (ERROR occured) One of two errors,
                                                    ; if AH=0x1 -> keyboard in secure mode, doesnot allow modifications or access to gate// else AH=0x86 -> function not supported
            
            cmp al,0x0                              ;else compare register al with 0, if al is zero then A20 is not available (disabled)
            je .enable_a20                          ;jump to label if al is zero (A20 disabled) so we must enable it by going to the label .enable_a20
            mov si,a20_enabled_msg                  ;move msg to si
            call bios_print                         ;calll function bios_print to print string
            jmp .enabled_done                            ;unconditional jump to label
            
        .enable_a20:
            mov ax,0x2401                           ;load 0x2401 to ax function number to enable a20 gate when int 0x15 is issued
            int 0x15                                ;issue bios interrupt on function in ax 0x2402
            jc .error                               ;jump to label if not  A20 gate enabled -> error happened so flag is set 
            jmp .check_gate                         ; If not enabled re-check again // if enabled check again also 

        .error:
            cmp ah, 0x1                             ;compare ah to 0x1 -> keyboaed in secure  (error1)
            je .keyboard_unavailable                    ;jump to label if ah=0x1
                cmp ah,0x86                         ; compare ah to 0x86 -> function not supported (error2)
            je .Function_not_supported               ;jump to label if ah=0x86
            jmp .unknown_error                      ; if we reach here then it is not one of the above error so print unkown error
        .keyboard_unavailable:
            mov si, keyboard_controller_error_msg   ;move msg to si
            call bios_print                         ;call function bios_print // to print the string
            jmp hang                                ;jump to hang label
        .Function_not_supported:
            mov si, a20_function_not_supported_msg   ;move msg to si
           call bios_print                         ;call function bios_print // to print the string
            jmp hang                                ;jump to hang label
        .unknown_error:
            mov si, unknown_a20_error  ;move msg to si
            call bios_print                         ;call function bios_print // to print the string
            jmp hang                                ;jump to hang label
        
        .enabled_done:
    popa                                ; Retrieve all the regitser from the stack
    ret                                 ;return to function caller and execute the next instruction after the caller one

