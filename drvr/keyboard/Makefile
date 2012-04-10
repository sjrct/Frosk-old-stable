#
# cga_text driver Makefile
#
# written by sjrct
#

SHELL   = /bin/sh

TARGET  = keyboard.drvr

$(TARGET): src/*
	nasm src/keyboard.asm -o $@

.PHONY: clean
clean:
	rm $(TARGET) $(OBJS) 
