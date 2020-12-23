%define PAGE_PRESENT_WRITE 0x3  ;011b
%define PAGE_PRESENT_WRITE 0x3 ; 011b
%define MEM_PAGE_4K 0x1000
%define PDP_Full 0x200 ;; to check if the page directory pointers -> reached their maximum (200h) (512 bytes)
%define PD_Full 0x200 ;; to check if page directory is full -> reached their maximum (200h) (512 bytes)
%define PTE_Full 0x200 ;; to check if the page table entries are full -> reached their maximum (200h) (512 bytes)
%define PML4_Full 0x4 ;; check if the page map level 4 is full reached its maximum of 4h (4 bytes)
%define memory_regions_table  0x21018



;;Declarations
Memory dq       0x0   ;; variable with the physical address and will be incremented by 0x1000 (4096) in the loops
PML4_Pointer dq 0x100000 ;; pointer to the address of page map level 4
PTE_Pointer dq  0x103000 ;; pointer to the address of the Page table entries
PDP_Pointer dq  0x101000 ;; the address of the Page ditectory pointers
PD_Pointer dq   0x102000 ;; pointer to the current address of the page directory
pointer dq 0x103000 ;; pointer to be freely moved around for use to save the current states of the pointers or the previous states and they are prone to change
PML4_Counter dq 0x0 ;; counter for the page map level 4 to use in the loops
PTE_Counter dq 0x0 ;; counter for the page table entries to use in the loops
PDP_Counter dq 0x0 ;; counter for the page directory to use in the loops
PD_Counter dq 0x0 ;; counter for page directory to use in the loops
max_size dq 0x140000000 ;; this maximum size we were able to derive it from the memory regions that we did in stage 1 last line


page_table_map:

;; intializating all the pointers to point at the part after mapping the 2MB that we mapped in stage 2
xor r8,r8 ;; making sure they are zero
xor r9,r9 ;; making sure they are zero
pushaq ;; defined as macro -> that pushes all 64 bit registers to stack / rax/rbx/rcx/r8-r15
  ;; we didn't use the rax pointer, to not mix it with other values, if it has a certain function number to exeucte
        ;; it acts works in a hierarchial behaviour of layers by which the each pointer points to the other ant the other points to the next, etc...
        ;; until reaching to the Page table entry pointer which opens up and creates the page tables and after finishing we repeat the procedure until reaching the 
        ;; end of the memory (finished mapping) 
        ;; setting the vaiables and starting the hierarchy then we will enter the loops to execte them
        mov r8, QWORD[PML4_Pointer]    ; storing the value that the pointer of "page map level 4" is pointing at now, in the register r8
        mov r9, QWORD[PDP_Pointer]     ;storing the value that the pointer of "page directory pointers" is pointing at now, in the register rbx
        or r9, PAGE_PRESENT_WRITE  ;;; make the present and read or write bits to 1
        mov [r8], r9              ;;moving the address of the PDP_pointer to the PML4_pointer VALUE
        inc QWORD[PML4_Counter] ;;increment PML4 counter 
        
        mov r8, QWORD[PDP_Pointer]    ;storing the value that the pointer of "page directory pointers" is pointing at now, in the register r8
        mov r9, QWORD[PD_Pointer]      ;storing the value that the pointer of "page directory" is pointing at now, in the register r9
        or r9, PAGE_PRESENT_WRITE  ;; make the present and read or write bits to 1
        mov [r8], r9              ; ;; moving the address of the PD_pointer to the PDP_pointer VALUE
        inc QWORD[PDP_Counter]   ;increment PDP counter 


        mov r8, QWORD[PD_Pointer]       ;storing the value that the pointer of "page directory pointers" is pointing at now, in the register r8
        mov r9, QWORD[PTE_Pointer]      ;storing the value that the pointer of "page Table Entries" is pointing at now, in the register rbx
        or r9, PAGE_PRESENT_WRITE  ;; make the present and read or write bits to 1
        mov [r8], r9              ;;moving the address of the PD_pointer to the PTE_pointer VALUE
        inc QWORD[PD_Counter]   ;increment PD counter
        
        jmp _PTE_Loop               ;;go to PTE loop to start the execution of the four for loops from inside to outside
        
        ;; The start of the four loops
                ;;PML4
                _PML4_Loop:
               
                        xor r8, r8 ;; making sure it is zero    
                        xor r9,r9 ;; making sure it is zero

                    add QWORD[pointer], MEM_PAGE_4K ;When we get here the second time -> because we started from inside -> we must move the pointer or add to it 0x1000 to point to the next empty region to map
                    mov QWORD[PDP_Counter], 0x0     ;reseting the counter to start mapping from the beginning to avoid any clashes
                    
                    mov r8, QWORD[pointer]     ;moving the address of the empty region that we are pointing at using our free-roaming pointer into reg r8
                    mov QWORD[PDP_Pointer], r8         ;moving the value of r8 to the address of PDP pointer
                    or r8, PAGE_PRESENT_WRITE      ; ;; make the present and read or write bits to 1
                    
                    add QWORD[PML4_Pointer], 0x8        ;Pointing to the next entry in PML4
                    mov r9, QWORD[PML4_Pointer]        ;moving that address into new reg r9
                    mov[r9], r8                   ;  moving the address of PDP_Pointer into the value of PML4_pointer
                     inc QWORD[PML4_Counter]   ;increment PML4 counter by 1

                            ;;PDP
                            _PDP_Loop:
                                         mov rsi,mapping
                                        call video_print

                                add QWORD[pointer], MEM_PAGE_4K ;; the next level after PML4->When we get here the second time -> because we started from inside -> we must move the pointer or add to it 0x1000 to point to the next empty region to map
                                mov QWORD[PD_Counter], 0x0  ;;reseting the counter to start mapping from the beginning to avoid any clashes
                                
                                mov r8, QWORD[pointer] ;moving the address of the empty region that we are pointing at using our free-roaming pointer into reg r8
                                mov QWORD[PD_Pointer], r8      ;moving the value of r8 to the address of PDP pointer
                                or r8, PAGE_PRESENT_WRITE  ;; ;; make the present and read or write bits pf the PD pointer to 1
                                
                                add QWORD[PDP_Pointer], 0x8     ;Pointing to the next entry in PDP
                                mov r9, QWORD[PDP_Pointer]     ;;moving that address into new reg r9
                                mov[r9], r8               ; moving the address of PDP_Pointer into the value of PML4_pointer
                                inc QWORD[PDP_Counter];; increment PDP counter  

                                        ;;PD
                                        _PD_Loop: 
                                               xor rdx, rdx
                                                mov rdx, QWORD[PML4_Pointer]
                                             mov cr3, rdx  
                                            
                                            add QWORD[pointer], MEM_PAGE_4K  ;; the next level after PD-> which actually looks at the physical memory->When we get here the second time -> because we started from inside -> we must move the pointer or add to it 0x1000 to point to the next empty region to map
                                            mov QWORD[PTE_Counter], 0x0     ;;reseting the counter to start mapping from the beginning to avoid any clashes
                                            
                                            mov r8, QWORD[pointer]  ;moving the address of the empty region that we are pointing at using our free-roaming pointer into reg r8
                                            mov QWORD[PTE_Pointer], r8         ;moving the value of r8 to the address of PTE pointer
                                            or r8, PAGE_PRESENT_WRITE      ;;; ;; make the present and read or write bits pf the PTE pointer to 1
                                            
                                            add QWORD[PD_Pointer], 0x8          ;;Pointing to the next entry in PTE
                                            mov r9, QWORD[PD_Pointer]          ;moving that address into new reg r9
                                            mov[r9], r8                   ;moving the address of PTE_Pointer into the value of PD_pointer
                                             inc QWORD[PD_Counter];; ;increment PTE counter by 1  
                                               
                                                ;; PTE-> the loop that points to the physcal memory
                                                _PTE_Loop:
                                                        xor rax, rax    ;set rax to zero
                                                        mov rax, QWORD[Memory]   ;store current physical address to map to rax
                                                        cmp rax, QWORD[max_size]        ;compare to max size and jumpt to exit label if equal
                                                        je _finish_mapping
                                                        cmp QWORD[Memory], 0xFFFFF ;check if address is in 1MB region and ignore check region type if true
                                                        mov rsi,Memory
                                                        jge _type_reg_check
                                                        _continueMapping:
                                                        xor r8, r8   ;;making sure it is zero
                                                        xor r9, r9;; making sure it is zero
                                                        mov r8, QWORD[PTE_Pointer]       ;; moving pte_pointer into register r8
                                                        mov r9, QWORD[Memory]   ;; storing the memory physical address to map, in r9
                                                        or r9, PAGE_PRESENT_WRITE     ; make the present and read or write bits to 1
                                                        mov [r8], r9                 ;; moving the address of physical memory into the value of PTE_Pointer
                                                        add QWORD[Memory], MEM_PAGE_4K   ;; increment the memory physical address by 0x1000 (4k)
                                                       _region_cant_be_mapped: ;; not type 1
                                                       _MapNext:
                                                        add QWORD[PTE_Pointer], 0x8           ; increment the pointer to the next entry
                                                        inc QWORD[PTE_Counter];;;; increment the PTE counter by 1  
                                                        cmp QWORD[PTE_Counter], PTE_Full   ; check if the Page table entries reached their end ; the page table is full (reached the maximum of 200h == (512 bytes))
                                                        
                                                        
                                                        jl _PTE_Loop  ;; continue mapping if we didnot reach the maximum
                                                        
                                                        
                                                        cmp QWORD[PML4_Counter], PML4_Full;;check if page table level 4 is is completed (reached 4 bytes)
                                                        je _finish_mapping

                                                        cmp QWORD[PDP_Counter], PDP_Full  ;check if PDP is full (reached 512 bytes)then we should go to PML4 Loop and create a new Entry in it and then continue
                                                        je _PML4_Loop
                                                        
                                                        cmp QWORD[PD_Counter], PD_Full    ;check if PD is FULL ( reached 512 bytes) then we should go to PDP loop and create a new entry in it and then continue
                                                        je _PDP_Loop

                                                                                        ;;else continue building the PTE entries so we go to the PD loop
                                                            ;; they will keep looping untill reaching the end of PML4 and then we are finisher
                                                        
                                                        jmp _PD_Loop   ; if we finish with the PTE entries then jump to PD to repeat the process and continue build or create new PTE // but when we rerutn there we should zero out the counter and add 0x1000 to the PTE pointer to create a whole new PTE then we stard the loop again

                                                        ;;else finish mapping

 ;##FUNCTIONS
_finish_mapping:
    popaq
    ret

;;#####################################################
_type_reg_check:
call _get_region_num ;; we get here mem region typess
jmp _check_if_type_can_be_mapped ;; now after having the region type we will check 
;; after returning

_check_if_type_can_be_mapped: ;;
cmp ecx, 0x1 ; if we are in the first region then we will map normally
je _MemTypeRegion1 ;; label that jumps to continue mapping abovr
;;elsee
_MemTypeRegion2_3_4_5: ;; other types that cannot be mappes
add QWORD[rsi],0x1000 ;; increment by 1000 to point at the next one
;; then go to a label that will skip the other
;jmp _memory_check ;; go back and repeat
jmp _region_cant_be_mapped ;; if it is now increment the memory by 1000 and continue as this mem address cant be mapped
_MemTypeRegion1:
;;TESTING
;xor rdi,rdi 
;mov edi,ecx
;call bios_print_hexa
;call kernel_halt
jmp _continueMapping