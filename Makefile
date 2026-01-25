DEVICE := AT28C256
BIN_FILE := rom.bin
SRC := samix.s screen_4bit.s init.s util.s print_stack.s print_splash.s echo.s
#SRC := 4bit_test.s screen_4bit.s

rom.bin:${SRC}
	vasm -Fbin -dotdir -wdc02 -o $@ $<
install:rom.bin
	minipro -p ${DEVICE} -w ${BIN_FILE} -u


.PHONY: install
