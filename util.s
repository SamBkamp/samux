;;clobbers sreg, x, y and a
div_by_ten:
        pha
        phx
        clc
        ldx #$08
dividing_loop:
        rol value               ;rotate quotient and mantissa
        rol remainder

;;a is dividend - divisor
        sec
        lda remainder
        sbc #10
        bcc ignore_result       ;discard if not divisible here

        sta remainder
ignore_result:
        dex
        bne dividing_loop

        rol value               ;shift last carry bit into bottom of value
        plx
        pla
        rts

;;easy as pie
div_by_hex:
        phx
        ldx #$00
        stx remainder
        ldx #$04
hex_div_loop:
        clc
        rol value
        rol remainder
        dex
        bne hex_div_loop
        plx
        rts
