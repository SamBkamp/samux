        .include "addresses.s"
        .org $8000

splash: .asciiz "samix kernel :3"
version_num: .asciiz "v0.2.3"
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

        jsr init_ports
        jsr init_timer
        jsr init_screen

        cli

_loop:
        lda program_sreg
        and #$01
        bne _loop

        ora #$01
        sta program_sreg
        jsr clear_screen
        ldy #$00                ;print to lcd
        jsr print_kernel_splash
        jmp hand_off_to_user_space

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
        .include "sash/sash.s"

;;printing kernel splash
        .include "./print_routines/print_splash.s"

;;code for stack splash printing
        .include "./print_routines/print_stack.s"

;;init code for ports and timers
        .include "./kernel_utils/init.s"

;;screen related boiler plate code
        .include "./lcd/screen.s"

;;utility code
        .include "./kernel_utils/util.s"

;;syscall handlers
        .include "./kernel_utils/syscall.s"

splash_art:
        .incbin "./splash_screens/jelly_splash.raw"

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
        and #%10000000          ;check if int is set in ifr
        bne service_timer
service_syscall:                ;this whole section functions as an indexed jsr call (ie. implementing the nonexistend jsr (#,x) )
        ldy #>exit_irq           ;load hi byte of return address
        phy
        ldy #<exit_irq           ;load lo byte of return address
        phy                     ;store data on the stack for rts later
        ldy irq_y_store
        lda irq_a_store
        jmp (syscall_table, x)
        ;this doesn't fall through as the return address is set for exit_irq
service_timer:
        bit T1CL
        jsr incr_timer
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
        .word write_lcd
        .word write_serial

;; jump table
        .org $FFFA
        .word _nmi
        .word _start
        .word _irq
