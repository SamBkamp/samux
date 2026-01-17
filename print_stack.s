print_stack_splash:

        lda counter
        cmp #$ff
        bne end_print_stack_splash

        lda #$01
        tsb program_sreg

        jsr print_stack_prefix

        lda #$01
        jsr go_to_line          ;go to second line

;;hex prefix
        lda #"0"
        ldx #$00
        brk
        lda #"x"
        jsr print_char
        
        jsr print_stack_address
end_print_stack_splash:
        rts


print_stack_prefix:
        pha
        jsr clear_screen
        jsr return_home
        ldx #$0
print_stack_loop:
        lda hello_msg, x
        beq exit_stack_hello
        jsr print_char
        inx
        jmp print_stack_loop
exit_stack_hello:
        pla
        rts

print_stack_address:
        jsr div_by_hex

        lda remainder           ;print remainder of divide 
        cmp #$0A          ;if not greater than 10        
        bcc not_letter    ;only add ascii "0"
        clc
        adc #("A"-10)           ;minus ten because lowest letter is 0x0A = 10
        jmp print_stack_char
not_letter:
        clc
        adc #"0"
print_stack_char:
        jsr print_char

        lda value               ;check if any data left in value to div
        bne print_stack_address ;keep dividing if yes
        rts

