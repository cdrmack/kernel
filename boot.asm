;;; nasm -f bin boot.asm -o boot.bin
;;; ndisasm boot.bin
;;; qemu-system-x86_64 -drive file=boot.bin,format=raw

    ORG 0x0
    BITS 16                     ; real mode is 16 bit, this is the initial operating mode

    jmp 0x7C0:start             ; this sets code segment

start:
    cli                         ; clear interrupts
    mov ax, 0x7C0               ; 0x7C00 is where BIOS should copy the bootloader to the RAM
    mov ds, ax                  ; data segment
    mov es, ax                  ; extra segment
    mov ax, 0x00
    mov ss, ax                  ; stack segment
    mov sp, 0x7C00              ; stack pointer (it grows downwards)
    sti                         ; enable interrupts
    mov si, string              ; store address of the string inside si

print_loop:
    lodsb                       ; load byte at DS:SI (data segment, si register is the offset) into al and increment si
                                ; DS * 16 + SI = 0x7C0 * 16 + SI = 0x7C00 + SI

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
