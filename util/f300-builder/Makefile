#
# f207-builder: Makefile
#
# written by sjrct
#

SHELL   = /bin/sh
CC      = gcc
CCFLAGS = -c -Wall
LDFLAGS = 
TARGET  = f300-builder

TSRCS   = main.c fs.c parser.c error.c
SRCS	= $(TSRCS:%=src/%)

TOBJS	= $(SRCS:.c=.o)
OBJS	= $(TOBJS:src/%=obj/%)


.PHONY: all
all: $(SRCS) $(TARGET)

$(TARGET): obj $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $@

obj:
	mkdir obj

obj/%.o: src/%.c
	$(CC) $(CCFLAGS) $< -o $@

.PHONY: clean
clean:
	rm $(OBJS) $(TARGET)

