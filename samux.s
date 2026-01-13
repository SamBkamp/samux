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
control_bit_mask = %11100000

counter = $00                   ;location of the counter
last_toggle = $03
program_sreg = $04              ;flag variable for software use
display_counter = $05

;;two 1 byte values
value = $0200
remainder = $0201


        .org $8000

splash: .asciiz "samux kernel :3"
version_num: .asciiz "v0.0.1"
hello_msg: .asciiz "hiii"
number: .byte "A"
_start:
        lda #$0                 ;init counter
        sta counter
        sta counter+$1
        sta counter+$2
        sta last_toggle
        sta program_sreg
        sta remainder
        sta remainder+1

        jsr init_ports
        jsr init_timer
        jsr init_screen

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
        lda program_sreg
        and #$01
        bne _loop

        lda counter
        cmp #$ff
        bne _loop

        lda #$01
        sta program_sreg

        jsr print_hello

        lda number
        sta value

        lda #$01
        jsr go_to_line
        jsr print_stack

        jmp _loop


print_display_counter:
        pha
        jsr return_home
        lda display_counter
        jsr print_char
        pla
        rts

print_hello:
        pha
        jsr clear_screen
        jsr return_home
        ldx #$0
print_hello_loop:
        lda hello_msg, x
        beq exit_print_hello
        jsr print_char
        inx
        jmp print_hello_loop
exit_print_hello:
        pla
        rts

print_stack:
        jsr div_by_hex

        lda remainder           ;print remainder of divide
        clc
        adc #"0"
        jsr print_char


        lda value               ;check if any data left in value to div
        bne print_stack         ;keep dividing if yes
        rts

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

;;screen related boiler plate code
        .include "util.s"


incr_timer:
        inc counter
        bne exit_incr_timer
        inc counter+$1
        bne exit_incr_timer
        inc counter+$2
exit_incr_timer:
        rts

_nmi:
        rti
_irq:
        pha
        bit T1CL
        jsr incr_timer
exit_irq:
        pla
        jsr toggle_led
        rti

;; jump table
        .org $FFFA
        .word _nmi
        .word _start
        .word _irq
