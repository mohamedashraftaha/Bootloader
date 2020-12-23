;*******************************************************************************************************************
;; as a referencecstart_location   dq  0x0  ; A default start position (Line # 8)
;; end 0xB8FA0
;; we changed the name from bios to video 
start_loc_pit dq 1918 ;; the loocation of the pic statement on the screen (after the successfully mapped statement)
end_location dq 0xB8FA0 ;; the end of the screen
video_print_hexa:  ; A routine to print a 16-bit value stored in di in hexa decimal (4 hexa digits)
cmp rsi,0x1 ; comapring the value in rsi (if 0x1 then it is PIT label)
je .print_pit ; if the rsi is == to 0x1 then jump to .print_pit label
;; else print all other hexa numbers ( drive and ATA parameters)
pushaq ;; pushing all general purpose registers into the stack
mov rbx,0xB8000          ; set BX to the start of the video RAM
;mov es,bx               ; Set ES to the start of teh video RAM
    add bx,[start_location] ; Store the start location for printing in BX
    mov rcx,0x10                                ; Set loop counter for 4 iterations, one for eacg digit
    ;mov rbx,rdi                                ; DI has the value to be printed and we move it to bx so we do not change ot
    .loop:                                      ; Loop on all 4 digits

            mov rsi,rdi                           ; Move current bx into si
            shr rsi,0x3C                          ; Shift SI 60 bits right 
            mov al,[hexa_digits+rsi]             ; get the right hexadcimal digit from the array           
            mov byte [rbx],al     ; Else Store the charcater into current video location
            inc rbx                ; Increment current video location
            mov byte [rbx],1Eh    ; Store Blue Background, Yellow font color
            inc rbx                ; Increment current video location

            shl rdi,0x4                          ; Shift bx 4 bits left so the next digits is in the right place to be processed
            dec rcx                              ; decrement loop counter
            cmp rcx,0x0                          ; compare loop counter with zero.
            jg .loop                            ; Loop again we did not yet finish the 4 digits
    add [start_location],word 0x20 ;; incrementing the start location  
    popaq ;; popping all general registers from stack
    ret ;; returning to the main file to execute the next statement in the main (third stage.asm) file (if needed)
    .print_pit: ;; label to print the pit
    pushaq ;; pushing all general registers into the stack
    mov rbx,0xB8000          ; set BX to the start of the video RAM
    ;mov es,bx               ; Set ES to the start of teh video RAM
    add bx,[start_loc_pit] ; Store the start location for printing the pit in rbx , then we will keep incrementing the place untill it fills the whole screen and when
                            ; when it finishes we will clear screen and start printing from start
    
    add bl,0x2 ;; location of the PIT label on screen (trial and error)
    mov rcx,0x10                                ; Set loop counter for 4 iterations, one for eacg digit
    
    ;mov rbx,rdi                                ; DI has the value to be printed and we move it to bx so we do not change ot
    _loop_pit:                                      ; Loop on all 4 digits
            cmp rbx, 0xB8FA0 ;; check if the characters still in the valid printing region
            jge _scroll_screen                    ;; if rbx is greater than the end location -> we should start scrolling
            _continue_print_pit:
            mov rsi,rdi                           ; Move current bx into si
            shr rsi,0x3C                          ; Shift SI 60 bits right 
            mov al,[hexa_digits+rsi]             ; get the right hexadcimal digit from the array           
            mov byte [rbx],al     ; Else Store the charcater into current video location
            inc rbx                ; Increment current video location
            mov byte [rbx],1Eh    ; Store Blue Background, Yellow font color
            inc rbx                ; Increment current video location
            shl rdi,0x4                          ; Shift bx 4 bits left so the next digits is in the right place to be processed
            dec rcx                              ; decrement loop counter
            cmp rcx,0x0                          ; compare loop counter with zero.
            jg _loop_pit                            ; Loop again we did not yet finish the 4 digits
    add QWORD[start_loc_pit],160 ;; jumping to the next line to print the PIT timer label on the next line on the screen

    popaq ;; popping all registers from the stack
    ret ;; returning to the main file (third stage. asm) to execute the next statement in the makn file (if needed)
   ;######################################
   ;;##################################################################################################################################################
   ;; 1- removing the first line in the QEMU window and then shifting the screen up to have an empty line at the bottom of the screen
;;    2- then printing the PIT timer and shifting the screen up
;;#####################################################################################################################################################
   _scroll_screen:  ;; label to apply the feature of scrolling and shifting
        call _shifting_up ;; calling the shifting 
                                   ;Calls function that shift up
        jmp _continue_print_pit                   ;Returns to printing
        
    ;;####################################
        _shifting_up: ;; shifiting screen up label
 xor r9,r9
    mov rbx,0xB8000 ;; moving the address of the beginning of the video ram in r8

    ;Clears the 1st line and replaces the character with space and black text black background
    _remove_line: ;; remove line label
        mov byte[rbx],0x00                           ;Sets the color to be black background and black text (Making it hidden)
        inc rbx                                     ;Increments to point to next character
        cmp rbx, 0xB80A0                            ;Checks if it reached the end of the first line
        jl _remove_line                          ;Jumps if it didnt reach the end of the line

        ;; if we get here so we reached the end of line as we scanned all characters in the line 

    _shift: ;; ;label to shift all lines by 1 line  
        ;mov rsi, 0xB80A0                            ;moving the line size [hexa] into the rsi register to be compared
        ;limitation didnt work so we will move it to another register
        mov rbx,0xB80A0
        
        mov r10, 0xB8000                            ;r10 is a pointer to the address of the begininng of the video ram
        
        ;The loop 
        _shifting_up_loop:
        mov rsi,rbx                                 
        ;; this part removes the last line
            lodsb                                   ;loads byte into al ;;;Load character pointer to by SI into al
            mov byte [r10],al                       ;move the byte into location at the start of the VIDEO RAM
            inc r10                                 ;increments to the next
            mov byte[rbx],0x0                       ;remove the character ter on 
            inc rbx                                 ;increments to point it to second byte 
            ;;#######################################################
        ;; this part add new characters in the start of the video ram
            mov rsi,rbx
            ;; taken from the approach of video print of the skeleton
            lodsb                                   ; Load character pointer to by SI into al; ;Load character pointer to by SI into al
            mov byte[r10],al                        ;Sets color to be same as one in old location
            inc r10                                 ;increments to point to next character
            mov byte[rbx], 0x0                      ;Sets the background color to black of the old field in order for 2 string to not overlap
            inc rbx                                 ;increments rbx
            cmp rbx, [end_location]                        ; 8000+FA0=B8FA0, maximum, if maximum → exit the loop
            jl _shifting_up_loop
        mov rbx, 0xB8F00                            ;set rbx to point to 1st value of last line
        mov qword[start_location],0xF00             ;stores start location to be 1st value in last line 
        ret
;????????????????????????????????

;*******************************************************************************************************************
; THIS PART IS RELATED TO THE VIDEO PRINT FUNCTION (STRINGS)
video_print:
    pushaq
    mov rbx,0x0B8000          ; set BX to the start of the video RAM
    ;mov es,bx               ; Set ES to the start of teh video RAM
    add bx,[start_location] ; Store the start location for printing in BX
    xor rcx,rcx
video_print_loop:           ; Loop for a character by charcater processing
    cmp rbx, 0xB8FA0

    jge _scroll_screen2                    ;; if rbx is greater than the end location -> we should start scrolling
    _continue_print_pit2:

    lodsb                   ; Load character pointer to by SI into al
    cmp al,13               ; Check  new line character to stop printing
    je out_video_print_loop ; If so get out
    cmp al,0                ; Check  new line character to stop printing
    je out_video_print_loop1 ; If so get out
    mov byte [rbx],al     ; Else Store the charcater into current video location
    inc rbx                ; Increment current video location
    mov byte [rbx],1Eh    ; Store Blue Backgroun, Yellow font color
    inc rbx                ; Increment current video location
                            ; Each position on the screen is represented by 2 bytes
                            ; The first byte stores the ascii code of the character
                            ; and the second one stores the color attributes
                            ; Foreground and background colors (16 colors) stores in the
                            ; lower and higher 4-bits
    inc rcx
    inc rcx
    jmp video_print_loop    ; Loop to print next character
out_video_print_loop:
    xor rax,rax
    mov ax,[start_location] ; Store the start location for printing in AX
    mov r8,160
    xor rdx,rdx
    add ax,0xA0             ; Add a line to the value of start location (80 x 2 bytes)
    div r8
    xor rdx,rdx
    mul r8
    mov [start_location],ax
    jmp finish_video_print_loop
out_video_print_loop1:
    mov ax,[start_location] ; Store the start location for printing in AX
    add ax,cx             ; Add a line to the value of start location (80 x 2 bytes)
    mov [start_location],ax
finish_video_print_loop:
    popaq
ret
;*********************************************************
           
           ;; SCROLLING of the video_print part → texts and strings 
           _scroll_screen2:
           xor r9, r9
           xor r11,r11 
        call _shifting_up2
                                   ;Calls function that shift up
        jmp _continue_print_pit2                   ;Returns to printing
        
     _shifting_up2:
    mov r9,0xB8000
    _remove_line2:
        mov byte[r9],0x00                           ;Sets the color to be black background and black text (Making it hidden)
        inc r9                                     ;Increments to point to next character
        cmp r9, 0xB80A0                            ;Checks if it reached the end of the first line
        jl _remove_line2                          ;Jumps if it didnt reach the end of the line

    ;Shifts all character by 160 (1 line) up by using register that points to source field and other that points to destination field
    _shift2:
        mov r9, 0xB80A0                            ;rbx should be in 2nd line as this will move the characters to r11
        mov rax, 0xB8000                            ;r11 should initially point to 1st line as this is the new place for the character
        
        ;The loop
        _shifting_up_loop2:
                ;; this part removes the last line
            mov rsi,r9                             ;rsi is needed for loadsb
            lodsb                                   ;loads byte into al ;;;Load character pointer to by SI into al
            mov byte [rax],al                     ;move the byte into location at the start of the VIDEO RAM
            inc rax                                  ;increments to the next
            mov byte[r9],0x0                       ;;remove the character ter on 
            inc r9                                 ;increments to point it to second byte
        ;;#######################################################
        ;; this part add new characters in the start of the video ram
            mov rsi,r9                           
            lodsb                                    ; Load character pointer to by SI into al; ;Load character pointer to by SI into al
            mov byte[rax],al                        ; Sets color to be same as one in old location
            inc rax                                 ;increments to point to next character
            mov byte[r9], 0x0                      ;Sets the background color to black of the old field in order for 2 string to not overlap
            inc r9                                 ;increments r9
            cmp r9, [end_location]                        ; 8000+FA0=B8FA0, maximum, if maximum → exit the loop
            jl _shifting_up_loop2
        mov r9, 0xB8F00                            ;set rbx to point to 1st value of last line
        mov qword[start_location],0xF00             ;stores start location to be 1st value in last line 
        ret                                        
