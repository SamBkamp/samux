_main = dit_dah
;;one byte data
counter_index = $0202
;;amount of bytes printed
string_len_counter = $0203
;;8 bytes max
string = $0204

dit_dah:
        lda #$00
        sta string
        sta string+$01
        sta string+$02
        sta string+$03
        sta string+$04
        sta string+$05
        sta string+$06
        sta string+$07
        sta string_len_counter
        jsr clear_screen
        lda #">"
        jsr print_char
        jsr debounce_delay      ;so that start btn doesn't roll over and print garbage on first loop
dit_dah_loop:
        lda PORTA
        and #BTN_A              ;check if A pressed
        bne A_NOT_PRESSED

        lda #"0"                ;print . if yes
        jsr print_char
        ldx string_len_counter
        lda string, x
        asl                     ;add 0 to lsb of current letter
        sta string, x
        jsr debounce_delay
A_NOT_PRESSED:
        lda PORTA
        and #BTN_B              ;check if b pressed
        bne B_NOT_PRESSED

        lda #"1"                ;print - if yes
        jsr print_char
        ldx string_len_counter
        lda string, x
        asl                     ;add 0 to lsb of current letter
        ora #$01                ;set lsb to 1
        sta string, x
        jsr debounce_delay
B_NOT_PRESSED:
        lda PORTA
        and #BTN_START
        bne START_NOT_PRESSED

        jsr clear_screen        ;clear display, also homes
        lda #">"
        jsr print_char

        lda #$01                ;go to second line
        jsr go_to_line
        inc string_len_counter
        jsr print_string_stored

        lda #$00
        jsr go_to_line
        lda #%00010100          ;cursor/display shift one to the right
        sta PORTB
        jsr lcd_instruction_send
        jsr debounce_delay
START_NOT_PRESSED:
        jmp dit_dah_loop
        rts

print_string_stored:
        phx
        pha
        ldx #$00
        cpx string_len_counter
        beq end_stored_loop
print_stored_loop:
        lda string, x
        jsr print_char
        inx
        cpx string_len_counter
        bne print_stored_loop
end_stored_loop:
        pla
        plx
        rts

;;god I hate busy loops
;;even though this isn't AS bad thanks to the wai instruction
debounce_delay:
        pha
        lda counter
        sta counter_index
debounce_delay_loop:
        wai
        lda counter
        clc
        sbc #$0F
        cmp counter_index
        bne debounce_delay_loop
        pla
        rts
