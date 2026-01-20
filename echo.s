_main = echo
char = $0300
;;9600 baud = ~104us per bit
echo:
        jsr clear_screen
        lda #">"
        ldx #$00                ;print
        brk                     ;syscall
        nop
print_stuff:
        jsr wait_start_bit
        jmp print_stuff

        rts

wait_start_bit:
        lda PORTA
        and #%00001000
        bne wait_start_bit      ;pin 3 is high at idle

        jsr half_bit_time

        ldx #$08
rx_bit:
        jsr bit_time
        lda PORTA
        and #%00001000
        bne recv_1              ;check incoming bit
        clc                     ;we recieved a zero
        jmp rx_done
recv_1:                         ;we recieved a one
        sec
        nop
        nop
rx_done:
        ror char                ;rotate in new bit
        dex
        bne rx_biti

print_rx_char:
        jsr bit_time           ;wait for stop bit
        lda char
        cmp #$08                ;backspace character
        beq backspace
        ldx #$00
        brk
        nop
        rts

backspace:
        lda #%00010000          ;move cursor one to the left
        sta PORTB
        jsr lcd_instruction_send
        lda #" "                ;blank character
        ldx #$00                ;print
        brk                     ;syscall
        nop
        lda #%00010000          ;move cursor one to the left
        sta PORTB
        jsr lcd_instruction_send
        rts


half_bit_time:
        phx
        ldx #6
half_bit_time_loop:
        dex
        bne bit_time_loop
        plx
        rts

bit_time:
        phx
        ldx #13
bit_time_loop:
        dex
        bne bit_time_loop
        plx
        rts
