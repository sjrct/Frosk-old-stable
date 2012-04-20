#
# Makefile for showcolors
#
# written by sjrct
#

SHELL   = /bin/sh

CC      = gcc
TARGET  = showcolors

TSRCS   = showcolors.c
SRCS    = $(TSRCS:%=src/%)
TOBJS   = $(SRCS:.c=.o)
OBJS    = $(TOBJS:src/%=obj/%)

.PHONY: all
all: obj $(SRCS) $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) $(FROSK_LDFL) -o $@

obj:
	mkdir obj

obj/%.o: src/%.c
	$(CC) $(FROSK_CCFL) $< -o $@

.PHONY: clean
clean:
	rm $(OBJS) $(TARGET)
