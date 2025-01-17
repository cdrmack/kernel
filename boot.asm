;;; nasm -f bin boot.asm -o boot.bin
;;; ndisasm boot.bin
;;; qemu-system-x86_64 -hda boot.bin

    ORG 0x7C00                  ; this is where BIOS copies bootloader to the RAM
    BITS 16                     ; real mode is 16 bit, this is the initial operating mode

start:
    mov ah, 0xE                 ; display char
    mov al, 'W'
    int 0x10                    ; call BIOS interrupt

hang:
    jmp hang                    ; infinite loop to avoid crash

    times 510 - ($ - $$) db 0   ; boot sector is always 512 bytes, fill the rest with 0s
    dw 0xAA55                   ; boot sector signature
