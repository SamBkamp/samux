E = %00001000
RW = %00000100
RS = %00000010
LCD_CTL_MASK = %00001110

stupid_delay:
        phx
        ldx #$ff
stupid_loop:
        nop
        nop
        nop
        nop
        nop
        nop
        dex
        bne stupid_loop
        plx
        rts
        
;;sreg
;;clobbers portb and porta
init_screen:
        pha
        phx
        ldx #$03          ;run function set 3 times for init by instr.
;;sending the function set 3 times to init by instruction
init_by_instr:
        lda #%00011100
        sta PORTB
        ora #E        
        sta PORTB
        and #!E
        sta PORTB
        dex	
        bne init_by_instr        
                
        lda #%00100000          ;function set, switch to 4 bit mode
        sta PORTB
        ora #E
        sta PORTB
        and #!E
        sta PORTB

        
        lda #%00101000          ;function set (4-bit mode, 2 line, 5x8)
        jsr lcd_instruction_send
        
        lda #%000001100          ;display byte 2 on, cur off, blink off
        jsr lcd_instruction_send        
        
        lda #%00000110          ;entry mode byte 2, incr, no scroll
        jsr lcd_instruction_send

        lda #%00000001          ;clear
        jsr lcd_instruction_send
        
        plx
        pla
        rts

;;sreg
clear_screen:
        pha
        
        lda #%00000001          ;clear display command
        jsr lcd_instruction_send
        pla
        rts

;;sreg
;;clobers porta
return_home:
        pha
        lda #%10000000                ;home hi byte
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
        jsr lcd_instruction_send
exit_go_to_line:
        pla
        rts

;; sreg
lcd_wait:
        pha
        phx
        lda #LCD_CTL_MASK       ;set drrb to input to read busy flag
        sta DDRB
reread:

        lda #RW                 ;set read/write
        sta PORTB

        lda #( E | RW )         ;set enable
        sta PORTB

        lda PORTB               ;read busy flag
        pha                     ;store result on stack

        lda #RW                 ;unset E
        sta PORTB
        
        lda #( RW | E )             ;set enable for lower nibble
        sta PORTB

        pla                     ;pull result back into a
        and #%10000000          ;compare bf w/ with accumulator
        bne reread

        lda #RW                 ;unset E
        sta PORTB

        lda #$ff                ;reset ddrb to output
        sta DDRB
        
        plx
        pla
        rts

lcd_instruction_send:
        pha
        pha

        jsr lcd_wait
        
        and #$F0
        jsr send_instruction_nibble

        pla
        and #$0F
        asl
        asl
        asl
        asl        
        jsr send_instruction_nibble
        
        pla
        rts

send_instruction_nibble:
        ora #E
        sta PORTB
        nop
        nop
        nop
        nop
        nop
        nop
        and #!E
        sta PORTB
        rts
        
print_char:
        pha
        pha

        jsr lcd_wait        
        and #$F0                ;mask top nibble
        ora #RS                 ;set RS
        sta PORTB
        ora #E        
        sta PORTB
        and #!E
        sta PORTB


        jsr lcd_wait
        pla
        asl                     ;shift lower nibble into top nibble
        asl
        asl
        asl
        ora #RS
        sta PORTB
        ora #E        
        sta PORTB
        and #!E
        sta PORTB
        
        pla
        rts
