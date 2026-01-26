# Samix - a W65C02 kernel made for Ben Eater's computer

Samix (Sam + unix, lol) is a pretty basic "kernel" for Ben Eater's 6502 computer. It sets up some systems like software-accessible timers, asynchronous execution and so  on. It also provides some run-time "libraries" for the screen, among other things.

This only works for the WDC6502, and uses its extended ISA.

## The startup flow

On startup, samix inits a 10khz counter (that is, a counter that increments 10k times a second) and stores the data in a 3 byte value at counter. It also initialises a 1 byte "status register" value intended to contain software flags. The kernel only uses the lsb, and no longer needs this once it hands program flow to the main program. Becareful not to clobber this if you decide to use it.

After this, the kernel splash will printed to the lcd. Then, once the counter reaches 255 (which is 2.56 seconds) it will print the top of the stack address. It will then sit in a loop. Pressing the "start" button (the button connected to PA3 on the VIA) at any point in this sequence will start the main program.


## user-defined program

After the kernel startup sequence, the kernel hands off control to the user defined program through a jump. The kernel will jump to _main (which will need to be defined at compile time) and the user defined program will take control. You can write your _main in the `samix.s` file, but I suggest to instead use vasm's `.include` directive.

If you simply compile this project without making any changes, ditdah will be compiled as the default "user-space" program.

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

| Name       | Description                                                                                         | A    | X | Y |
|------------|-----------------------------------------------------------------------------------------------------|------|---|---|
| print_char | prints char `char` to lcd                                                                           | char | 0 |   |
| div_by_ten | divides value in memory at location `value` by 10, puts remainder in memory at location `remainder` |      | 1 |   |
| _main      | the main program                                                                                    |      | 2 |   |