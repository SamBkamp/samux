dit_dah:
        jsr clear_screen
        lda #">"
        jsr print_char
dit_dah_loop:
        lda PORTA
        and #%00000100
        bne dit_dah_loop
        lda #"."
        jsr print_char
        jsr dumb_delay
        jmp dit_dah_loop

;;one byte data
counter_index = $0202
;;god I hate busy loops
;;even though this isn't AS bad thanks to the wai instruction
dumb_delay:
        pha
        lda counter
        sta counter_index
dumb_delay_loop:
        wai
        lda counter
        clc
        sbc #$0F
        cmp counter_index
        bne dumb_delay_loop
        pla
        rts
