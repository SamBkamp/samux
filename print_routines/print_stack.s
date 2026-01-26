print_stack_splash:
        pha
        phx
        phy
        ldy #$00                ;for write syscall
        jsr print_stack_prefix
        lda #$01
        jsr go_to_line          ;go to second line

;;hex prefix
        lda #"0"
        ldx #$00
        brk
        nop

        lda #"x"
        brk
        nop

        jsr print_stack_address
_end_print_stack_splash:
        ply
        plx
        pla
        rts


print_stack_prefix:
        pha
        jsr clear_screen
        jsr return_home
        ldx #$0
_print_stack_loop:
        lda hello_msg, x
        beq _exit_stack_hello
        phx
        ldx #$00
        brk
        nop
        plx
        inx
        jmp _print_stack_loop
_exit_stack_hello:
        pla
        rts

print_stack_address:
        jsr div_by_hex

        lda remainder           ;print remainder of divide
        cmp #$0A          ;if not greater than 10
        bcc _not_letter    ;only add ascii "0"
        clc
        adc #("A"-10)           ;minus ten because lowest letter is 0x0A = 10
        jmp _print_stack_char
_not_letter:
        clc
        adc #"0"
_print_stack_char:
        ldx #$00
        brk
        nop

        lda value               ;check if any data left in value to div
        bne print_stack_address ;keep dividing if yes
        rts
