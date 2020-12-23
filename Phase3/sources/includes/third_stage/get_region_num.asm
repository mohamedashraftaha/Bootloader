_get_region_num:
mov r14, memory_regions_table ; add of the table of entries
_region_loop: ;; we have 4 types ; type 1 ,type 2, type 3, type 4 , the only one that is valid is type 1 otherwise we skip it
mov rax, QWORD[r14]  ; 1st region
mov rbx, QWORD[r14+8] ; increment to next region
add rax,rbx ; getting the addr

;;TESTING
;mov rdi,r14
;add rdi,16
;mov ecx, DWORD[rdi]
;xor rdi,rdi
;mov edi,ecx
;call bios_print_hexa
;call kernel_halt

cmp rax,QWORD[rsi] ; checking if we reached the end if 
;cmp QWORD[rsi],rax
jle _type_region
add r14,0x18 ; increment to the next entry [24 bytes] of the table if above isn't satisfied 
jmp _get_region_num ;; recursively

_type_region:
xor ecx,ecx ; make sure it is zero before any operation
mov ecx, DWORD[r14+16] ; increment register by 16 bytes
;;TESTING
;xor rdi,rdi  
;mov edi,ecx
;call bios_print_hexa
;call kernel_halt
ret
;ret