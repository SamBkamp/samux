PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
ACR = $600B
T1CL = $6004
T1CH = $6005
IFR = $600D
IER = $600E

program_sreg = $00              ;flag variable for software use
counter = $01                   ;location of the counter
last_toggle = $04

;;one byte values
value = $0200
remainder = $0201
irq_a_store = $0202
irq_x_store = $0203
irq_y_store = $0204

        .org $8000

splash: .asciiz "samix kernel :3"
version_num: .asciiz "v0.1.2"
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

        tsx
        stx value

        jsr init_ports
        jsr init_timer
        jsr init_screen

        jsr print_kernel_splash

_loop:
        lda counter+$1
        cmp #$02
        beq hand_off_to_user_space


        lda program_sreg        ;check if program sreg lsb is set
        and #$01
        bne _loop

        jsr print_stack_splash
        jmp _loop

hand_off_to_user_space:
        jsr _main
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

 ;;include your actual program file here
        .include "echo.s"

;;printing kernel splash
        .include "print_splash.s"

;;code for stack splash printing
        .include "print_stack.s"

;;init code for ports and timers
        .include "init.s"

;;screen related boiler plate code
        .include "screen_4bit.s"

;;utility code
        .include "util.s"

;;syscall handlers
        .include "syscall.s"


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
        sta irq_a_store
        stx irq_x_store
        sty irq_y_store
        lda IFR
        and #%10000000
        bne service_timer
service_syscall:                ;this whole section functions as an indexed jsr call (ie. implementing the nonexistend jsr (#,x) )
        lda irq_a_store
        ldy #>exit_irq           ;load hi byte of return address
        phy
        ldy #<exit_irq           ;load lo byte of return address
        phy                     ;store data on the stack for rts later
        ldy irq_y_store
        jmp (syscall_table, x)
        ;this doesn't fall through as the return address is set for exit_irq
service_timer:
        bit T1CL
        jsr incr_timer
        jsr toggle_led
        lda PORTA
        and #%00000010
        bne exit_irq
        lda #%00000010
        ora program_sreg
        sta program_sreg
exit_irq:
        nop
        lda irq_a_store
        ldx irq_x_store
        ldy irq_y_store
        rti

;;syscall table, the page before the jump table
        .org $FF00
syscall_table:
        .word write
        .word div_by_ten
        .word _main

;; jump table
        .org $FFFA
        .word _nmi
        .word _start
        .word _irq
