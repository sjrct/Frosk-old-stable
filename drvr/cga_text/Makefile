#
# cga_text driver Makefile
#
# written by sjrct
#

SHELL   = /bin/sh

TARGET  = cga_text.drvr

$(TARGET): src/*
	nasm src/cga_text.asm -o $@

.PHONY: clean
clean:
	rm $(TARGET) $(OBJS) 
