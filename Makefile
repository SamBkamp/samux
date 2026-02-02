DEVICE := AT28C256
BIN_FILE := rom.bin
SRC := samix.s addresses.s kernel_utils/* print_routines/* lcd/* sash/*

rom.bin:${SRC}
	vasm -Fbin -dotdir -wdc02 -o $@ $<
install:rom.bin
	minipro -p ${DEVICE} -w ${BIN_FILE} -u


.PHONY: install
