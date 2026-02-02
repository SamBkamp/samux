write:
        cpy #$0
        beq lcd_write
        jsr write_serial
        jmp end_write
lcd_write:
        jsr write_lcd
end_write:
        rts
