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
print_splash_loop:
        lda splash, x
        beq prep_version_print
        jsr print_char
        inx
        jmp print_splash_loop

prep_version_print:
        lda #$01
        jsr go_to_line
        ldx #$0

print_version_loop:
        lda version_num, x
        beq _loop
        jsr print_char
        inx
        jmp print_version_loop

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

;;init code for ports and timers
        .include "init.s"

;;screen related boiler plate code
        .include "screen.s"

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
