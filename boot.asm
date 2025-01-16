;;; nasm -f bin boot.asm -o boot.bin
;;; ndisasm boot.bin
;;; qemu-system-x86_64 -hda boot.bin

    ORG 0x7c00
    BITS 16

start:
    mov ah, 0eh
    mov al, 'W'
    mov bx, 0
    int 0x10

    jmp $

    times 510-($ - $$) db 0
    dw 0xAA55
