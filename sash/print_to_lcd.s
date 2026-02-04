print_charbuf_to_lcd:
        jsr clear_screen
        ldx #$02
_print_to_lcd_loop:
        lda char_buffer, x
        cpx char_buffer_idx
        beq _print_to_lcd_exit
        jsr write_lcd
        inx
        jmp _print_to_lcd_loop
_print_to_lcd_exit:
        rts
