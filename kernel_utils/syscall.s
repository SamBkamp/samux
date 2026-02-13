write:
        cpy #$0
        beq lcd_write
        jsr write_serial
        jmp end_write
lcd_write:
        jsr write_lcd
end_write:
        rts

;;uses lfsr to generate random byte
;;generator polynomial = x^8 + x^6 + x^5 + x^4 + 1
next_random:
        phx
        ldx #$00                ;repeat 8 times (8 new bits - new byte)
        stx random_internal_state ;init the initial state
_next_random_loop:
        lda random              ;load previous state
        clc
        pha                       ;save prev state to stack
        rol random              ;rotate state
        rol random_internal_state ;store lsb to internal state (will become output)

;;eor bit 5
        asl random
        eor random

;;eor bit 4
        asl random
        eor random
;;eor bit 3
        asl random
        eor random

;;shift new bit into bit 0 position
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
;;probably unecessary
        and #$01

;;combine xor output bit into right shifted output
        sta random              ;save new bit in random
        pla                     ;pull original state into a
        asl                     ;shift over to make space for new bit
        ora random              ;or with new bit
        sta random              ;store our new state into random

        inx                     ;repeat step 8 times
        cpx #$08
        bne _next_random_loop
;;generated 8 new bits
        lda random_internal_state
        plx
        rts
