_main = echo
char = $0300

ACIA_DATA_REG = $5000
ACIA_STATUS_REG = $5001
ACIA_CMD_REG = $5002
ACIA_CTRL_REG = $5003

;;status reg masks
RXR_FULL_MASK = %00001000
TXR_FULL_MASK = %00010000

;;ctrl reg settings
STOP_BIT_N = %00000000          ;1 stop bit
WORD_LEN = %00000000            ;8 bit word
RX_CLK_SRC = %00010000          ;internal generator
SEL_BAUD_RATE = %00001110       ;9600 baud

;;cmd reg settings
PARITY_MODE = %00000000         ;odd parity tx/rx
PARITY_MODE_ENABLED = %00000000 ;no parity enabled
ECHO_MODE = %00000000           ;rx normal mode (no echo)
IRQ_CTRL = %00001000            ;irq pulled low, tx irq disabled
IRQ_ENABLED = %00000010         ;irq disabled
DTR_ENABLED = %00000001         ;dtr ready
;;9600 baud = ~104us per bit
echo:
        jsr clear_screen

        lda #">"
        jsr print_char

        ;init acia
        lda #$00
        sta ACIA_STATUS_REG         ;write something to the status reg to reset chip
        lda #( STOP_BIT_N | WORD_LEN | RX_CLK_SRC | SEL_BAUD_RATE )
        sta ACIA_CTRL_REG
        lda #( PARITY_MODE | PARITY_MODE_ENABLED | ECHO_MODE | IRQ_CTRL | IRQ_ENABLED | DTR_ENABLED )
        sta ACIA_CMD_REG

event_loop:
        lda ACIA_STATUS_REG
        and #$08
        beq event_loop

        lda ACIA_DATA_REG
        jsr print_char
        jmp event_loop
        rts
