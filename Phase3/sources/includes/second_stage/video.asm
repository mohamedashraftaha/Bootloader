%define VIDEO_BUFFER_SEGMENT                    0xB000
%define VIDEO_BUFFER_OFFSET                     0x8000
%define VIDEO_BUFFER_EFFECTIVE_ADDRESS          0xB8000
%define VIDEO_SIZE      0X0FA0    ; 25*80*2
    video_cls_16:
            pusha                                   ; Save all general purpose registers on the stack

                  ; This function need to be written by you.
                  cld                    ; Set forward direction for STOSD
                  mov ax, VIDEO_BUFFER_SEGMENT ;; move into ax the start of the screen  ;;Beginning of VGA memory in segment 0xA000
                  mov es, ax             
                  mov al,'' ;; move into al space to clear any written code on screen
                  mov ah,0x00 ;; the colout of the screen is set to 0h which is the black color
                  mov edi, VIDEO_BUFFER_EFFECTIVE_ADDRESS   ; Set the address of video into edi
                  mov cx, VIDEO_SIZE  ; Move the video size 25x80x2 into cx
                  rep stosd              ; rep -> repeats a string instruction the number of times specified in the count register
                                    ; stosd->stores a doubleword from EAX register into the destination operand
                                    ; clear video RAM
             



            popa                                ; Restore all general purpose registers from the stack
            ret

