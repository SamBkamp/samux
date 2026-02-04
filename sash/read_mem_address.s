
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
