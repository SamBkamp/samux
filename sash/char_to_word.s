add_nibble_to_word:
        pha
        phx
        eor #$30                ;converts ascii 0-9 to digit
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
        jsr div_by_hex
        jsr print_low_nibble
        txa
        jsr print_low_nibble
        ply
        plx
        rts
