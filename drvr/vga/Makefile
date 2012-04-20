#
# vga driver Makefile
#
# written by sjrct
#

SHELL   = /bin/sh

TARGET  = vga.drvr

$(TARGET): src/*
	nasm src/vga.asm -o $@

.PHONY: clean
clean:
	rm $(TARGET) $(OBJS) 
