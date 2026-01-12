;;sreg
;;clobbers portb and porta
init_screen:
        pha
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
        pla
        rts

;;sreg
;;clobbers porta
clear_screen:
        pha
        lda #$1                 ;clear display command
        sta PORTB
        jsr lcd_instruction_send
        pla
        rts

;;sreg
;;clobers porta
return_home:
        sei
        pha
        lda #%00000010                ;return home
        sta PORTB
        jsr lcd_instruction_send
        pla
        cli
        rts

;;takes line in reg a (only reads lsb)
go_to_line:
        pha
        and #$ff
        beq exit_go_to_line     ;if a is 0, we're already on line 0, exit
        lda #%11000000          ;use set ddram to move to line 2 (quicker, no need return home or right shift loop). address set to 0x40 which is start of line 2
        sta PORTB
        jsr lcd_instruction_send
exit_go_to_line:
        pla
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
        lda #E                  ;toggle enable
        sta PORTA
        lda #0
        sta PORTA
        jsr lcd_wait
        rts

;; changes port a
print_char:
        sta PORTB
        lda #RS                  ;turn on RS
        sta PORTA

        lda #(RS | E)            ;toggle enable and RS
        sta PORTA
        lda #RS                 ;un toggle enable but keep RS
        sta PORTA
        jsr lcd_wait
        rts
