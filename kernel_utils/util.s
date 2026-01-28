;;clobbers sreg, x, y and a
divisor = $0208
remainder = $0209
div_by_ten:
        pha
        phx
        clc
        ldx #$08
dividing_loop:
        rol divisor               ;rotate quotient and mantissa
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

        rol divisor               ;shift last carry bit into bottom of value
        plx
        pla
        rts

;;takes divisor in a register
;;returns result in a, stores remainder in remainder
div_by_hex:
        pha
        and #$0f                ;store low nibble in remainder
        sta remainder
        pla

        lsr                     ;move hi nibble into low nible pos
        lsr
        lsr
        lsr
        rts
