print_kernel_splash:
        pha
        phx
        phy
        ldx #$0
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
        tya                     ;different newline implementation based on target
        and #$FF
        beq _prep_version_lcd   ;for lcd
        lda #RETURN             ;for serial connection
        jsr write_serial
        lda #NEWLINE
        jsr write_serial
        ldx #$00
        jmp _print_version_loop
_prep_version_lcd:
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
