print_kernel_splash:
        ldx #$0
print_splash_loop:
        lda splash, x
        beq prep_version_print
        inx
        jsr print_char
        jmp print_splash_loop

prep_version_print:
        lda #$01
        jsr go_to_line
        ldx #$0

print_version_loop:
        lda version_num, x
        beq print_kernel_splash_exit
        jsr print_char
        inx
        jmp print_version_loop

print_kernel_splash_exit:
        rts
