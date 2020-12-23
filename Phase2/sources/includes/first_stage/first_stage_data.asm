;************************************** first_stage_data.asm **************************************

boot_drive db 0x0 ; storing boot drive number
lba_sector dw 0x1; the variable that will read the next sector on the disk (0x1 because it is set in the lba_2_chs file with 0x0 as this is stored on hardware) {check lba_2_chs file }
spt dw 0x12 ; storing the number of the sectors and tracks of the booting device and setting its default to the floppy parameters
hpc dw 0x2 ;storing the the number of the heads and cylinders of the booting device and setting its default to the floppy parameters

Cylinder dw 0x0 ; initializing the variable to be used in INT operations (mass storage interrupts)
Head db 0x0 ;initializing the variable to be used in INT operations (mass storage interrupts)
Sector dw 0x0 ; initializing the variable to be used in INT operations (mass storage interrupts)

disk_error_msg          db 'Disk Error',13,10,0 ;string to display 'Disk error' (0 adds null terminator at the end to indicate the end of the string and 13,10 for return and newline )
fault_msg               db 'Unknown Boot Device',13,10,0 ; string to display 'Unknown Boot Device' (0 adds null terminator at the end to indicate the end of the string and 13,10 for return and newline )
booted_from_msg         db 'Booted From',0 ;string to display 'Booted From' (0 adds null terminator at the end to indicate the end of the string and 13,10 for return and newline )
floppy_boot_msg         db 'floppy',13,10,0 ;string to display 'floppy' (0 adds null terminator at the end to indicate the end of the string and 13,10 for return and newline )
drive_boot_msg          db 'Disk',13,10,0 ;string to display 'Disk' (0 adds null terminator at the end to indicate the end of the string and 13,10 for return and newline )
greeting_msg            db '1st Stage Loader', 13,10,0 ;string to display '1st Stage Loader' (0 adds null terminator at the end to indicate the end of the string and 13,10 for return and newline )
second_stage_loaded_msg db 13,10,'2nd Stage loaded, press any key to resume!', 0  ;string to display '2nd Stage Loaded, press any key to resume!' (0 adds null terminator at the end to indicate the end of the string and 13,10 for return and newline )
dot                     db '.',0 ; string to display '.' indicating the progress bar (0 adds null terminator at the end to indicate the end of the string)
newline                 db 13,10,0 ; string for displaying newline (0 adds null terminator at the end to indicate the end of the string and 13,10 for return and newline )
disk_read_segment       dw 0 ; initializing variable  by zero
disk_read_offset        dw 0 ; initializing variable by zero
