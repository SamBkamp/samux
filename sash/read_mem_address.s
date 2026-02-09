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
        jsr ascii_to_nibble
        asl
        asl
        asl
        asl
        pha

        inx
        lda char_buffer, x
        jsr ascii_to_nibble

        tsx                   ;get the stack pointer (points to free pos)
        eor $0101, x          ;stack starts at 0100, but we start the index from 0101 to account for the fact that the stack pointer points to one passed (ie lower, address-wise) than the most recent pushed byte
;;we could use an inx instruction and index from the bottom of the stack like normal but that wastes a byte of rom space and a few cycles
        jsr print_byte_to_hex

        plx
        pla                     ;pull a pushed earlier
        pla
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
