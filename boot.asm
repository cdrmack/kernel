    ORG 0x0
    BITS 16                     ; real mode is 16 bit, this is the initial operating mode

_start:
    jmp short start
    nop

    times 33 db 0               ; create 33 bytes, this is for BIOS Parameter Block

start:
    jmp 0x7C0:step2             ; set code segment to 0x7C0 and jump to step2 label

handle_zero:                    ; custom interrupt 0 (divide by 0)
    mov ah, 0xE                 ; display char
    mov al, '0'
    mov bx, 0x0
    int 0x10                    ; call BIOS interrupt
    iret                        ; return from the interrupt

handle_one:                     ; custom interrupt 1
    mov ah, 0xE
    mov al, '1'
    mov bx, 0x0
    int 0x10
    iret

step2:
    cli                         ; clear interrupts
    mov ax, 0x7C0               ; 0x7C00 is where BIOS should copy the bootloader to the RAM
    mov ds, ax                  ; data segment
    mov es, ax                  ; extra segment
    mov ax, 0x0
    mov ss, ax                  ; stack segment
    mov sp, 0x7C00              ; stack pointer (it grows downwards)
    sti                         ; enable interrupts

    cli
    mov word[ss:0x00], handle_zero   ; override first byte (interrupt zero) in the interrupts vector table
                                     ; we use ss which is 0x0 because [0x0] (without segment specified) would use ds by default which is 0x7C0
    mov ax, cs                  ; store code segment
    mov word[ss:0x02], ax       ; set segment of the interrupt handler

    mov word[ss:0x04], handle_one
    mov word[ss:0x06], ax
    sti

    ;; mov ax, 0x0
    ;; div ax                      ; divide by 0, will trigger interrupt 0
    ;; int 0                            ; call interrupt zero directly
    int 1

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
