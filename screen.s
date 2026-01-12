init_screen:
        lda #%00000001          ;clear display
        sta PORTB
        jsr lcd_instruction_send

        lda #%00111000          ;function set (set 8-bit mode, 2 line displayt, 5x8 font)
        sta PORTB
        jsr lcd_instruction_send

        lda #0                  ;set control pins to 0
        sta PORTA
        jsr lcd_instruction_send

        lda #%00001110          ;display on, cur on, blink off
        sta PORTB
        jsr lcd_instruction_send

        lda #%00000110          ;entry mode, incr, no scroll
        sta PORTB
        jsr lcd_instruction_send
        rts


;; sreg
lcd_wait:
        pha
        lda #0                  ;set drrb to input to read busy flag
        sta DDRB
reread:
        lda #RW
        sta PORTA
        lda #(E|RW)             ;compile-time constant eval I think
        sta PORTA
        lda PORTB               ;read busy flag
        and #%10000000          ;compare with top bit (bf)
        bne reread

        lda #RW
        sta PORTA

        lda #$ff                ;reset ddrb to output
        sta DDRB
        pla
        rts
       
;; changes a
lcd_instruction_send:
        jsr lcd_wait
        lda #E                  ;toggle enable
        sta PORTA
        lda #0
        sta PORTA
        rts

;; changes port a
print_char:
        jsr lcd_wait
        sta PORTB
        lda #RS                  ;turn on RS
        sta PORTA

        lda #(RS | E)            ;toggle enable and RS
        sta PORTA
        lda #RS                 ;un toggle enable but keep RS
        sta PORTA
        rts
