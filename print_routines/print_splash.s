print_kernel_splash:
        pha
        phx
        phy
        ldx #$0
        ldy #$00 ;for write syscall
_print_splash_loop:
        lda splash, x
        beq _prep_version_print
        inx
        phx
        ldx #$00
        brk
        nop
        plx
        jmp _print_splash_loop
_prep_version_print:
        lda #$01
        jsr go_to_line
        ldx #$0
_print_version_loop:
        lda version_num, x
        beq _print_kernel_splash_exit
        phx
        ldx #$00
        brk
        nop
        plx
        inx
        jmp _print_version_loop
_print_kernel_splash_exit:
        ply
        plx
        pla
        rts
