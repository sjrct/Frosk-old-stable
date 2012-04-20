#
# Makefile for building libraries for frosk programs
#
# written by sjrct
#
# creates: cstd.a fapi.a
#

SHELL    = /bin/sh

CC       = gcc
CCFL     = -nostdinc -nostdlib -m32 -I$(TOPDIR)/include
AR       = ar

LIBCSTD  = cstd.a
LIBFAPI  = fapi.a

# add source file names here
CSTDSRCB = ctype.c rand.c string.c malloc.c time.c stdlib.c
FAPISRCB = frosk.c frusr.c

CSTDSRCS = $(addprefix cstd/src/,$(CSTDSRCB))
CSTDOBJS = $(addprefix cstd/obj/,$(CSTDSRCB:.c=.o))
FAPISRCS = $(addprefix fapi/src/,$(FAPISRCB))
FAPIOBJS = $(addprefix fapi/obj/,$(FAPISRCB:.c=.o))


.PHONY: all
all: fapi/obj cstd/obj $(LIBCSTD) $(LIBFAPI)

fapi/obj:
	mkdir fapi/obj

cstd/obj:
	mkdir cstd/obj

$(LIBCSTD): $(CSTDOBJS)
	$(AR) rcu $@ $^

cstd/obj/%.o: cstd/src/%.c
	$(CC) -c $< $(CCFL) -o $@
	
$(LIBFAPI): $(FAPIOBJS)
	$(AR) rcu $@ $^

fapi/obj/%.o: fapi/src/%.c
	$(CC) -c $< $(CCFL) -o $@
	
.PHONY: clean
clean:
	-rm $(LIBCSTD) $(LIBFAPI) fapi/obj/* cstd/obj/*
