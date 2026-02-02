_main = echo
;;control characters
NEWLINE = $0a
RETURN = $0d

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
        ldx #$00
        ldy #$01
        brk
        nop

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
        lda char_buffer
        jsr shell_instruction
        lda #">"                ;print shell char
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        jmp _event_loop_end
_not_return:                    ;store char in a to char buffer
        ldx char_buffer_idx
        sta char_buffer, x
        inc char_buffer_idx
        jsr uart_bug_loop
_event_loop_end:
        jmp event_loop
        rts

shell_instruction:
        pha
        phy
        phx
        ldx char_buffer_idx
        cpx #$01                ;shell instructions can only be one char
        bne _next_shell_instruction
        cmp #"v"
        bne _next_shell_instruction
        ldy #$01
        jsr print_kernel_splash
        jmp _shell_end
_next_shell_instruction:
        cmp #"s"
        bne _next_shell_instruction2
        ldy #$01
        jsr print_stack_splash
        jmp _shell_end
_next_shell_instruction2:       ;i have got to come up with a better naming scheme
        cmp #"r"
        bne _instruction_not_recognised
        ldy #$01
        jsr read_mem_address
_shell_end:                     ;resets the char_buffer and print \r\n
        ldy #$00
        sty char_buffer_idx     ;reset char buffer idx to start of buffer
        lda #RETURN
        jsr write_serial
        lda #NEWLINE
        jsr write_serial
        jmp _shell_instruction_exit
_instruction_not_recognised:
        jsr print_char_buffer
_shell_instruction_exit:
        plx
        ply
        pla
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
        jsr write_serial
        lda #RETURN
motd_not_newline_char:
        jsr write_serial
        inx
        jmp print_motd_loop
end_loop:
        lda #RETURN
        jsr write_serial
        lda #NEWLINE
        jsr write_serial
        rts

read_mem_address:
        pha
        phx
        lda #$00
        sta conversion_word
        sta conversion_word+1
        lda char_buffer_idx
        sec
;;if str len < 3 || str len >= 7
        cmp #$3
        bcc address_invalid
        cmp #$07
        bcs address_invalid
        clc
        ldx #$02
read_mem_loop:
        lda char_buffer, x
        jsr add_nibble_to_word
        inx
        cpx char_buffer_idx
        bne read_mem_loop

        lda conversion_word+1
        jsr print_byte_to_hex
        lda conversion_word
        jsr print_byte_to_hex
        lda #":"
        jsr write_serial
        lda (conversion_word)
        jsr print_byte_to_hex
        plx
        pla
        rts
error_msg: .asciiz "arguments not recognised"
address_invalid:
        ldx #$00
address_invalid_loop:
        lda error_msg, x
        beq exit_address_invalid_loop
        jsr write_serial
        inx
        jmp address_invalid_loop
exit_address_invalid_loop:
        plx
        pla
        rts

add_nibble:
        pha
        sbc #$30
        pha
        txa
        and #$01
        beq no_nibble_shift     ;if number is even, branch
        pla
        asl
        asl
        asl
        asl
        pha
no_nibble_shift:
        pla
        ora conversion_word+1
        sta conversion_word+1
        pla
        rts

        .include "sash/char_to_word.s"
        .include "serial_connection/serial.s"
