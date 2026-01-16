;;sreg
;;clobbers portb and porta
init_screen:
        pha

;;sending the function set 3 times to init by instruction
        lda #%00111000          ;function set (set 8-bit mode, 2 line displayt, 5x8 font)
        sta PORTB
        jsr lcd_instruction_send

        lda #%00111000          ;function set (set 8-bit mode, 2 line displayt, 5x8 font)
        sta PORTB
        jsr lcd_instruction_send

        lda #%00111000          ;function set (set 8-bit mode, 2 line displayt, 5x8 font)
        sta PORTB
        jsr lcd_instruction_send

        lda #%00001110          ;display on, cur on, blink off
        sta PORTB
        jsr lcd_instruction_send

        lda #%00000110          ;entry mode, incr, no scroll
        sta PORTB
        jsr lcd_instruction_send

        jsr clear_screen

        pla
        rts

;;sreg
clear_screen:
        pha
        lda #%00000001          ;clear display command
        sta PORTB
        jsr lcd_instruction_send
        pla
        rts

;;sreg
;;clobers porta
return_home:
        pha
        lda #%10000000          ;use set ddram to move to line 0
        sta PORTB
        jsr lcd_instruction_send
        pla
        rts

;;takes line in reg a (only reads lsb)
go_to_line:
        pha
        and #%00000001
        beq line_zero
        lda #%11000000          ;set ddram addr. to line 1
        jmp send_dd_ram
line_zero:
        lda #%10000000          ;set ddram addr. to line 0
send_dd_ram:
        sta PORTB
        jsr lcd_instruction_send
exit_go_to_line:
        pla
        rts

;; sreg
lcd_wait:
        pha
        lda #%00000000                  ;set drrb to input to read busy flag
        sta DDRB
reread:
        lda PORTA
        and #!LCD_CTL_MASK        ;reset all control bits
        sta PORTA

        ora #RW                 ;set read/write
        sta PORTA

        ora #E                  ;toggle enable
        sta PORTA

        lda PORTB               ;read busy flag
        and #%10000000          ;compare with top bit (bf)
        bne reread

        lda PORTA
        and #!E                  ;toggle enable
        sta PORTA

        lda #$ff                ;reset ddrb to output
        sta DDRB
        pla
        rts

lcd_instruction_send:
        pha
        jsr lcd_wait

        lda PORTA
        and #!LCD_CTL_MASK        ;reset all control bits
        sta PORTA

        ora #E                  ;set E
        sta PORTA

        and #(!E)               ;unset E
        sta PORTA

        pla
        rts

print_char:
        jsr lcd_wait
        sta PORTB
        pha

        lda PORTA
        and #!LCD_CTL_MASK        ;reset all control bits
        sta PORTA

        ora #RS                 ;turn on RS
        sta PORTA

        ora #E                  ;turn on e
        sta PORTA

        and #!E                 ;turn off e
        sta PORTA

        pla
        rts
