PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
ACR = $600B
T1CL = $6004
T1CH = $6005
IFR = $600D
IER = $600E

E = %10000000
RW = %01000000
RS = %00100000

counter = $00                   ;location of the counter
last_toggle = $03

        .org $8000

splash: .asciiz "samux kernel :3"
version_num: .asciiz "v0.0.1"	
_start:
        lda #$0                 ;init counter
        sta counter
        sta counter+$1
        sta counter+$2
        sta last_toggle

        jsr init_ports

        jsr init_screen

        jsr init_timer

        cli

        ldx #$0
print_loop:
        lda splash, x
        beq _loop
        jsr print_char
        inx
        jmp print_loop

_loop:
        jsr toggle_led
        jmp _loop

toggle_led:
        lda counter
        sec
        sbc last_toggle
        cmp #$f
        bcc end_toggle
        lda #$1
        eor PORTA
        sta PORTA
        lda counter
        sta last_toggle
end_toggle:
        rts

;;a, sreg
init_ports:
        lda #$ff                ;all pints port b output
        sta DDRB

        lda #%11111111          ;top 3 pins, bottom pin port a to output
        sta DDRA

        lda #$0                 ;init both ports to pull down
        sta PORTA
        sta PORTB

        rts

;;sreg
init_timer:
        pha
        lda #%01000000          ;free-run mode
        sta ACR

        lda #$19                ;int. every 10k cycles. @1mhz -> every 10ms (i think)
        sta T1CL
        lda #$27
        sta T1CH                ;init the counters (starts count down)

        lda #%11000000          ;set/clear, timer 1 high
        sta IER

        pla
        rts

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

_nmi:
        rti
_irq:
        pha
        lda T1CL
        inc counter
        bne exit_irq
        inc counter+$1
        bne exit_irq
        inc counter+$2
exit_irq:
        pla
        rti

;; jump table
        .org $FFFA
        .word _nmi
        .word _start
        .word _irq
