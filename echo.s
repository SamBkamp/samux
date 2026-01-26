_main = echo
char_buffer = $0300             ;uses full page
char_buffer_idx = $0400         ;one byte value



;;control characters
NEWLINE = $0a
RETURN = $0d

;;acia addresses
ACIA_DATA_REG = $5000
ACIA_STATUS_REG = $5001
ACIA_CMD_REG = $5002
ACIA_CTRL_REG = $5003

;;status reg masks
RXR_FULL_MASK = $08
TXR_FULL_MASK = %00010000

;;ctrl reg settings
STOP_BIT_N = %00000000          ;1 stop bit
WORD_LEN = %00000000            ;8 bit word
RX_CLK_SRC = %00010000          ;internal generator
SEL_BAUD_RATE = %00001111       ;19,200 baud

;;cmd reg settings
PARITY_MODE = %00000000         ;odd parity tx/rx
PARITY_MODE_ENABLED = %00000000 ;no parity enabled
ECHO_MODE = %00000000           ;rx normal mode (no echo)
IRQ_CTRL = %00001000            ;irq pulled low, tx irq disabled
IRQ_ENABLED = %00000010         ;irq disabled
DTR_ENABLED = %00000001         ;dtr ready
;;9600 baud = ~104us per bit
echo:
        ;init char buffer
        lda #$00
        sta char_buffer_idx

        ;init acia
        sta ACIA_STATUS_REG         ;write something to the status reg to reset chip
        lda #( STOP_BIT_N | WORD_LEN | RX_CLK_SRC | SEL_BAUD_RATE )
        sta ACIA_CTRL_REG
        lda #( PARITY_MODE | PARITY_MODE_ENABLED | ECHO_MODE | IRQ_CTRL | IRQ_ENABLED | DTR_ENABLED )
        sta ACIA_CMD_REG

        jsr print_motd
        lda #">"
        sta ACIA_DATA_REG
        jsr uart_bug_loop

event_loop:
        lda ACIA_STATUS_REG
        and #$08
        beq event_loop

;;new character recieved
        lda ACIA_DATA_REG
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        cmp #RETURN
        bne _not_return
;;return character sent
        lda #NEWLINE            ;send newline so we send back \r\n
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        jsr print_char_buffer
        lda #">"                ;print shell char
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        lda #$00                ;store 0 to char buffer if return was sent
_not_return:                    ;store char in a to char buffer
        ldx char_buffer_idx
        sta char_buffer, x
        inc char_buffer_idx
        jsr uart_bug_loop
_event_loop_end:
        jmp event_loop
        rts

print_char_buffer:
        pha
        phx
        ldx #$00
_print_char_buffer_loop:
        cpx char_buffer_idx     ;check if we reached idx
        beq _print_char_buffer_exit
        lda char_buffer, x
        inx
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        jmp _print_char_buffer_loop
_print_char_buffer_exit:
        ldx #$00
        stx char_buffer_idx     ;reset char buffer idx to start of buffer
        lda #RETURN
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        lda #NEWLINE
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        plx
        pla
        rts

print_motd:
        ldx #$00
print_motd_loop:
        lda splash_art, x
        beq end_loop
        cmp #NEWLINE
        bne motd_not_newline_char
        jsr serial_char
        lda #RETURN
motd_not_newline_char:
        jsr serial_char
        inx
        jmp print_motd_loop
end_loop:
        lda #RETURN
        jsr serial_char
        lda #NEWLINE
        jsr serial_char
        rts

serial_char:
        pha
serial_loop:
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        pla
        rts


uart_bug_loop:
        phx
        ldx #$ff
uart_bug_loop1:
        nop
        dex
        bne uart_bug_loop1

        plx
        rts
