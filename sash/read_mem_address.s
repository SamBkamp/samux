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


write_mem_address:
        pha
        phx

        lda #$00
        sta conversion_word
        sta conversion_word+1

        lda char_buffer_idx
        sec                     ;check if command is at least 3 bytes long
        cmp #$3
        bcc address_invalid

        ldx #$2                 ;start at 3rd byte ("w ...")
write_ma_loop:
        lda char_buffer, x      ;reading first argument (mem address)
        cmp #" "
        beq parse_data_byte

        cpx  char_buffer_idx
        beq address_invalid     ;if we encounter eos before space, invalid

        jsr add_nibble_to_word
        inx
        jmp write_ma_loop

parse_data_byte:
        lda conversion_word+1
        jsr print_byte_to_hex
        lda conversion_word
        jsr print_byte_to_hex
        lda #" "
        jsr write_serial
;;x should already be the index of the preceeding space
        inx                     ;point to first char of address
        lda char_buffer, x
        eor #$30                ;converts ascii 0-9 to digit
        rol
        rol
        rol
        rol
        sta conversion_word
        inx
        lda char_buffer, x
        eor #$30
        ora conversion_word
        jsr print_byte_to_hex

write_mem_address_exit:

        pla
        plx
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
