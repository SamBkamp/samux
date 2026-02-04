print_char_buffer:
        pha
        phx
        ldx #$00
_print_char_buffer_loop:
        cpx char_buffer_idx     ;check if we reached idx
        beq _print_char_buffer_exit
        lda char_buffer, x
        inx
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        jmp _print_char_buffer_loop
_print_char_buffer_exit:
        ldx #$00
        stx char_buffer_idx     ;reset char buffer idx to start of buffer
        lda #RETURN
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        lda #NEWLINE
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        plx
        pla
        rts

print_motd:
        ldx #$00
print_motd_loop:
        lda splash_art, x
        beq end_loop
        cmp #NEWLINE
        bne motd_not_newline_char
        jsr write_serial
        lda #RETURN
motd_not_newline_char:
        jsr write_serial
        inx
        jmp print_motd_loop
end_loop:
        lda #RETURN
        jsr write_serial
        lda #NEWLINE
        jsr write_serial
        rts
