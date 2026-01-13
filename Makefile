DEVICE := AT28C256
BIN_FILE := rom.bin
SRC := samux.s screen.s init.s util.s

rom.bin:${SRC}
	vasm -Fbin -dotdir -c02 -o $@ $<
install:rom.bin
	minipro -p ${DEVICE} -w ${BIN_FILE} -u


.PHONY: install
