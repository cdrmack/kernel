;;; nasm -f bin boot.asm -o boot.bin
;;; ndisasm boot.bin
;;; qemu-system-x86_64 -drive file=boot.bin,format=raw

    ORG 0x7C00                  ; this is where BIOS copies bootloader to the RAM
    BITS 16                     ; real mode is 16 bit, this is the initial operating mode

start:
    mov si, string              ; store address of the string inside si

print_loop:
    lodsb                       ; load byte at ds:si into al and increment si
    cmp al, 0                   ; check if end of string
    je done

    mov ah, 0xE                 ; display char
    int 0x10                    ; call BIOS interrupt

    jmp print_loop

done:
hang:
    jmp hang                    ; infinite loop to avoid crash

    string db 'hello from the bootloader!', 0

    times 510 - ($ - $$) db 0   ; boot sector is always 512 bytes, fill the rest with 0s
    dw 0xAA55                   ; boot sector signature
