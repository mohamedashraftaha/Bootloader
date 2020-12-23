;************************************** detect_boot_disk.asm **************************************
      detect_boot_disk: ; A subroutine to detect the the storage device number of the device we have booted from
                        ; After the execution the memory variable [boot_drive] should contain the device number
                        ; Upon booting the bios stores the boot device number into DL
                        pusha ; push all registers on the stack for further operations
                        mov si,fault_msg ; move the string fault message into register si
                        xor ax,ax ; in interrupt 13 when ax=0 is the function number to reset the device
                        int 13h  ; issue BIOS interrupt 13 with function 0 stored in ax -> which is used to reset the device
                        jc .exit_with_error ; if carry flag is set  ->  errors with resetting the device
                        mov si,booted_from_msg ;; else if carry flag is not set -> we will print a string "Booted from" into si
                        call bios_print ;; calling bios print to print message on screen "Booted from"
                        mov [boot_drive], dl ;; the boot drive number(id) is stored in dl automatically -> so we will booted into address [boot_drive]
                        cmp dl,0 ;; compare dl with zero
                        je .floppy ; if dl is zero so we are booting from a floppy
                        call load_boot_drive_params ;; else we are booting from a disk drive -> so we need to get the hard disk parameters
                         mov si,drive_boot_msg ;; after we get the parameters we will move the string "Disk" into si then jump to finish to print it on screen
                        jmp .finish
                        .floppy: ;; if we are booting from a floppy we dont need parameters as floppy disks have fixed geometry (parameters) already known
                        mov si,floppy_boot_msg ;; move the string "Floppy" into register si
                        jmp .finish ;; then jump to label finish where we will print on the screen "Floppy"
                        .exit_with_error: ;; if we got here so there is an error -> stop the program
                        jmp hang

                        .finish: ; if we got here so we either have one of the strings "Floppy" or "Disk"
                        call bios_print ;; print one of the strings "Floppy " or "Disk"
                        popa ;  we will retrieve the values from the stack
                        ret ; then return to execute the first instruction after the caller one
