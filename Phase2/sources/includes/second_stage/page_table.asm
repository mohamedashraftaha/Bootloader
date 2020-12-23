%define PAGE_TABLE_BASE_ADDRESS         0x0000
%define PAGE_TABLE_BASE_OFFSET          0x1000
%define PAGE_TABLE_EFFECTIVE_ADDRESS    0x1000
%define PAGE_PRESENT_WRITE              0x3  ; 011b
%define MEM_PAGE_4K                     0x1000

build_page_table:
    pusha  ;Save all general purpose registers on the stack

        ;This function need to be written by you.
        mov ax,PAGE_TABLE_BASE_ADDRESS
        mov es,ax
        xor eax,eax
        mov edi,PAGE_TABLE_BASE_OFFSET
        mov ecx, 0x1000
        xor eax,eax
        cld
        rep stosd
        mov edi,PAGE_TABLE_BASE_OFFSET
        ;PML4
        lea eax,[es:di + MEM_PAGE_4K]
        or eax, PAGE_PRESENT_WRITE
        mov [es:di], eax
        ;PDP
        add di, MEM_PAGE_4K
        lea eax, [es:di + MEM_PAGE_4K]
        or eax, PAGE_PRESENT_WRITE
        mov [es:di], eax
        ;PD
        add di, MEM_PAGE_4K
        lea eax, [es:di + MEM_PAGE_4K]
        or eax, PAGE_PRESENT_WRITE
        mov [es:di], eax
        ;PTE
        add di,MEM_PAGE_4K
        mov eax, PAGE_PRESENT_WRITE
        .pte_loop:
        mov [es:di], eax
        add eax, MEM_PAGE_4K
        add di, 0x8
        cmp eax, 0x200000
        jl .pte_loop

        mov si, pml4_page_table_msg
        call bios_print
       
    popa                                ; Restore all general purpose registers from the stack
    ret