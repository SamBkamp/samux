;;takes divisor in a register
;;returns result in a, stores remainder in x
div_by_hex:
        pha
        and #$0f                ;store low nibble in remainder
        tax
        pla

        lsr                     ;move hi nibble into low nible pos
        lsr
        lsr
        lsr
        rts

print_low_nibble:
        pha
        phx

        cmp #$0A                ;if not greater than 10
        bcc _nibble_not_letter  ;only add ascii "0"
        clc
        adc #("A"-10)    ;minus ten because lowest letter is 0x0A = 10
        jmp _print_nibble
_nibble_not_letter:
        adc #"0"
_print_nibble:
        ldx #$00
        brk
        nop

        plx
        pla
        rts
