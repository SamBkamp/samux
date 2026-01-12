DEVICE := AT28C256
BIN_FILE := rom.bin
SRC := splash_screen.s

rom.bin:${SRC}
	vasm -Fbin -dotdir -o $@ $^
install:rom.bin
	minipro -p ${DEVICE} -w ${BIN_FILE} -u


.PHONY: install
