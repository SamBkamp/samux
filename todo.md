# TODOs
pls help


### Define address spaces for user and kernel land programs - _easy_
We need to define space for user and kernel land programs, currently I've decided that the 0x0200 - 0x02FF page is for kernel use exclusively, but the zero page still needs to be divvied up

### Move the readme into a proper docs page - _annoying_
the readme.md is getting too long. It needs its own proper wiki/documentation page.

### Index syscalls better - _medium_
Currently the syscalls are indexed by 2 bytes (ie, syscalls are numbered 0, 2, 4, 6 etc) because each address is the absolute address of the routine which is a 16 bit word. I'd like the syscalls to be indexed by 1 byte, which probably needs to be done with a zero page jump table.

