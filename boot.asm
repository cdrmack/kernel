    ORG 0x0
    BITS 16                     ; real mode is 16 bit, this is the initial operating mode

_start:
    jmp short start
    nop

    times 33 db 0               ; create 33 bytes, this is for BIOS Parameter Block

start:
    jmp 0x7C0:step2             ; set code segment to 0x7C0 and jump to step2 label

step2:
    cli                         ; clear interrupts
    mov ax, 0x7C0               ; 0x7C00 is where BIOS should copy the bootloader to the RAM
    mov ds, ax                  ; data segment
    mov es, ax                  ; extra segment
    mov ax, 0x0
    mov ss, ax                  ; stack segment
    mov sp, 0x7C00              ; stack pointer (it grows downwards)
    sti                         ; enable interrupts

    ;; https://www.ctyme.com/intr/rb-0607.htm
    mov ah, 0x2                 ; read sector command
    mov al, 0x1                 ; how many sectors
    mov ch, 0x0                 ; low eight bits of cylinder number
    mov cl, 0x2                 ; sector number
    mov dh, 0x0                 ; head number
    mov bx, buffer              ; data buffer
    int 0x13                    ; interrupt for reading disk sector(s) into memory

    jc error                    ; jump if CF is set
    mov si, buffer
    call print
    jmp $

error:
    mov si, error_msg
    call print
    jmp $

print:
    mov bx, 0

.loop:
    lodsb                       ; load byte at DS:SI (data segment, si register is the offset) into al and increment si
                                ; DS * 16 + SI = 0x7C0 * 16 + SI = 0x7C00 + SI

    cmp al, 0                   ; check if end of string
    je .done

    mov ah, 0xE                 ; display char
    int 0x10                    ; call BIOS interrupt

    jmp .loop

.done:
    jmp $                       ; infinite loop to avoid crash

error_msg:
    db 'Failed to load sector', 0

    times 510 - ($ - $$) db 0   ; boot sector is always 512 bytes, fill the rest with 0s
    dw 0xAA55                   ; boot sector signature

buffer:
