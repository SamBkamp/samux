write_serial:
        pha
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        pla
        rts

uart_bug_loop:
        phx
        ldx #$90
_uart_bug_loop_wait:
        nop
        dex
        bne _uart_bug_loop_wait

        plx
        rts
