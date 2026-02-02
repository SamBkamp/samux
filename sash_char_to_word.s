add_nibble_to_word:
        pha
        phx
        eor #$30
        ldx #$04
;;shift word one nibble over to make space for next nibble
nibble_word_loop:
        clc
        rol conversion_word
        rol conversion_word+1
        dex
        bne nibble_word_loop

        ora conversion_word
        sta conversion_word
        plx
        pla
        rts

print_byte_to_hex:
        phx
        phy
        ldx #$02
        jsr div_by_hex_1
_print_bth_loop:
        cmp #$0A
        bcc _print_bth_not_letter
        clc
        adc #("A"-10)
        jmp _print_bth_nibble
_print_bth_not_letter:
        adc #"0"
_print_bth_nibble:
        jsr write_serial
        tya
        dex
        bne _print_bth_loop
        ply
        plx
        rts

div_by_hex_1:
        pha
        and #$0f
        tay
        pla

        lsr
        lsr
        lsr
        lsr
        rts
