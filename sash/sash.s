_main = echo
;;control characters
NEWLINE = $0a
RETURN = $0d
BACKSPACE = $08

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

        lda counter

        jsr print_motd
        ldy #$01
        jsr print_kernel_splash
        lda #RETURN
        jsr write_serial
        lda #NEWLINE
        jsr write_serial

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
        lda counter             ;add entropy
        eor random
        sta random

        lda ACIA_DATA_REG
        cmp #RETURN
        bne _check_backspace
_check_newline:
        sta ACIA_DATA_REG       ;send back \r
        lda #NEWLINE            ;send \n
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        lda char_buffer
        jsr shell_instruction
        lda #">"                ;print shell char
        sta ACIA_DATA_REG
        jsr uart_bug_loop
        jmp _event_loop_end

_check_backspace:
        cmp #BACKSPACE
        bne _not_ctrlchar

        lda char_buffer_idx     ;for some reason a bit instruction doesn't work here
        beq _event_loop_end     ;if char buffer idx is already 0, we don't need to do anything

        lda #BACKSPACE
        sta ACIA_DATA_REG       ;send backspace back
        jsr uart_bug_loop

        lda #" "                ;send whitespace to erase char
        sta ACIA_DATA_REG
        jsr uart_bug_loop

        lda #BACKSPACE          ;send backspace to realign terminal
        sta ACIA_DATA_REG
        jsr uart_bug_loop

        dec char_buffer_idx
        jmp _event_loop_end

_not_ctrlchar:                  ;store char in a to char buffer
        sta ACIA_DATA_REG       ;send character back
        ldx char_buffer_idx
        sta char_buffer, x
        inc char_buffer_idx
        jsr uart_bug_loop

_event_loop_end:
        jmp event_loop
        rts

unknown_command_string: .asciiz "unknown command"
help_string:
        .byte "Available commands:", RETURN, NEWLINE
        .byte "v - prints version splash", RETURN, NEWLINE
        .byte "s - prints current stack pointer location", RETURN, NEWLINE
        .byte "r xxxx - prints the byte at address xxxx, the address can be 1, 2, 3 or 4 bytes long", RETURN, NEWLINE
        .byte "w xxxx yy - writes the byte yy to address xxxx, address can be 1-4 bytes, byte needs to be 2 bytes. Hexademical representation", RETURN, NEWLINE
        .byte "P [str] - prints the string passed as argument to the LCD"
        .byte 0

shell_instruction:
        pha
        phy
        phx
        ldx char_buffer_idx
        cpx #$01
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
        bne _next_shell_instruction3
        ldy #$01
        jsr read_mem_address
        jmp _shell_end

_next_shell_instruction3:
        cmp #"P"
        bne _next_shell_instruction4
        jsr print_charbuf_to_lcd
        lda #RETURN
        jsr write_serial
        ldy #$00
        sty char_buffer_idx
        jmp _shell_instruction_exit

_next_shell_instruction4:
        cmp #"?"
        bne _next_shell_instruction5
        ldx #$00
_print_help_str_loop:
        lda help_string, x
        beq _shell_end
        jsr write_serial
        inx
        jmp _print_help_str_loop

_next_shell_instruction5:
        cmp #"w"
        bne _next_shell_instruction6
        jsr write_mem_address
        jmp _shell_end

_next_shell_instruction6:
        cmp #"q"
        bne _instruction_not_recognised
        jsr next_random
        jsr print_byte_to_hex
        jmp _shell_end

_instruction_not_recognised:
        ldx #$00
_instruction_nr_loop:
        lda unknown_command_string, x
        beq _shell_end
        jsr write_serial
        inx
        jmp _instruction_nr_loop

_shell_end:                     ;resets the char_buffer and print \r\n
        ldy #$00
        sty char_buffer_idx     ;reset char buffer idx to start of buffer
        lda #RETURN
        jsr write_serial
        lda #NEWLINE
        jsr write_serial

_shell_instruction_exit:
        plx
        ply
        pla
        rts


        .include "sash/print_to_lcd.s"
        .include "sash/sash_print_routines.s"
        .include "sash/read_mem_address.s"
        .include "sash/char_to_word.s"
        .include "serial_connection/serial.s"
