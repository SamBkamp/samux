write_serial:
        pha
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        pla
        rts

uart_bug_loop:
        phx
        ldx #$ff
_uart_bug_loop_wait:
        nop
        dex
        bne _uart_bug_loop_wait

        plx
        rts
