print_stack_splash:
        pha
        phx
        phy
;;set up output target
        cpy #$00
        beq _stack_splash_to_lcd
        jsr print_stack_prefix
        lda #RETURN
        jsr write_serial
        lda #NEWLINE
        jsr write_serial
        jmp _print_addr_hex_prefix
_stack_splash_to_lcd:
        jsr clear_screen
        jsr return_home
        jsr print_stack_prefix
        lda #$01
        jsr go_to_line          ;go to second line

;;print hex prefix 0x
_print_addr_hex_prefix:
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
        tsx
        txa                     ;div_by_hex takes arg in a reg and returns result in a reg
        jsr div_by_hex          ;will return first nibble in a and second nibble in y
        jsr print_low_nibble
        txa
        jsr print_low_nibble
        rts
