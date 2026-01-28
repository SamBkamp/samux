# Samix - a W65C02 kernel made for Ben Eater's computer
```
      _ -- ~~~ -- _
  .-~               ~-.
/         .--.         \
:     .--.'--'.--.      :
\     '--'.--.'--'      /
 _        '--'         _
   ~-._           _ .-~
        -- ~~~ --
```


Samix (Sam + unix, lol) is a pretty basic "kernel" for Ben Eater's 6502 computer. It sets up some systems like software-accessible timers, asynchronous execution and so  on. It also provides some run-time "libraries" for the screen, among other things.

Even though its called a kernel, its also a bios and a bootloader

This only works for the WDC6502, and uses its extended ISA.

## The startup flow

On startup, samix inits a 10khz counter (that is, a counter that increments 10k times a second) and stores the data in a 3 byte value at counter. It also initialises a 1 byte "status register" value intended to contain software flags. The kernel only uses the lsb, and no longer needs this once it hands program flow to the main program. Becareful not to clobber this if you decide to use it.

after this, the kernel splash will be printed to the lcd and and the kernel will hand off program control to the user program.


## user-defined program

After the kernel startup sequence, the kernel hands off control to the user defined program through a jump. The kernel will jump to _main (which will need to be defined at compile time) and the user defined program will take control. You can write your _main in the `samix.s` file, but I suggest to instead use vasm's `.include` directive.

## compilation

`./configure.sh` will set up the project files for your hardware

`make` will compile the binaries into a binary file called rom.bin

and `make install` will install it onto the AT28C256 rom chip using minipro


## syscalls

samix implements some syscalls which user-space programs can use by using the `brk` instruction

**IMPORTANT NOTE ABOUT SYSCALLS:**
A weird quirk with the brk instruction is that most assemblers treat it as a one-byte instruction, whereas the CPU treats it as a 2 byte instruction. This causes issues with return alignment in many cases. _if your assembler assembles brk as a one-byte instructrion, you must follow the brk immediately with a nop to preserve return-address alignment_. Example:

```asm
        ldx #$00    ;syscall number
        brk         ;call syscall
        nop         ;alignment
```

### syscall list

| Name        | Description                                                  | A    | X | Y   |
|-------------|--------------------------------------------------------------|------|---|-----|
| write       | prints char `char` to lcd (y = 0) or serial port (y = 1)     | char | 0 | 0/1 |
| print_char  | alias for write syscall to lcd                               | char | 2 |     |
| serial_char | alias for write sycall to serial out                         | char | 4 |     |



### Adress map for the BE6502

| Name       | Pins             | Hex             |NOTES             |
|------------|------------------|-----------------|------------------|
| RAM        | 0 0 X X X X X X  | 0x0000 - 0x3FFF |                  |
| ACIA*      | 0 1 0 1 X X X X  | 0x5000 - 0x5003 | bit 3 ignored    |
| VIA        | 0 1 1 0 X X X X  | 0x6000 - 0x600F |                  |
| INVALID*   | 0 1 1 1 X X X X  | 0x7000 - 0x7FFF | DO NOT ADDRESS   |
| ROM        | 1 X X X X X X X  | 0x8000 - 0xFFFF |                  |


**\* = only applicable to serial connection variant**