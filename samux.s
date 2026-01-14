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

program_sreg = $00              ;flag variable for software use
counter = $01                   ;location of the counter
last_toggle = $04

;;two 1 byte values
value = $0200
remainder = $0201


        .org $8000

splash: .asciiz "samux kernel :3"
version_num: .asciiz "v0.0.1"
hello_msg: .asciiz "stack starts at:"
_start:
        ldx #$FF
        txs

        lda #$0                 ;init counter
        sta counter
        sta counter+$1
        sta counter+$2
        sta last_toggle
        sta program_sreg
        sta remainder
        sta remainder+1

        tsx
        stx value

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

        jsr print_stack_prefix

        lda #$01
        jsr go_to_line

;;hex prefix
        lda #"0"
        jsr print_char
        lda #"x"
        jsr print_char

        jsr print_stack

        jmp _loop

print_stack_prefix:
        pha
        jsr clear_screen
        jsr return_home
        ldx #$0
print_stack_loop:
        lda hello_msg, x
        beq exit_stack_hello
        jsr print_char
        inx
        jmp print_stack_loop
exit_stack_hello:
        pla
        rts

print_stack:
        jsr div_by_hex

        lda remainder           ;print remainder of divide
        cmp #$0A          ;if not greater than 10
        bcc not_letter    ;only add ascii "0"
        clc
        adc #("A"-10)           ;minus ten because lowest letter is 0x0A = 10
        jmp print_stack_char
not_letter:
        clc
        adc #"0"
print_stack_char:
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
        jsr toggle_led
        pla
        rti

;; jump table
        .org $FFFA
        .word _nmi
        .word _start
        .word _irq
