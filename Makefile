#
# Frosk Makefile
#
# written by sjrct
#

SHELL       = /bin/sh
TARGET      = frosk.img

# name of dir/exec in prgm directory (for programs on frosk)
PRGMS_B     = start frash echo ls cls

# name of dir/exec in util directory (for programs to help build frosk)
UTILS_B     = f300-builder

# name of dir/binary in drivers directory (for drivers)
DRVRS_B     = cga_text keyboard

# default flags for C program compilation for frosk, provided for convience
# assumes that the compiler/linker is called two directory levels down
export TOPDIR     = $(shell pwd)
export FROSK_CCFL = -c -Wall -nostdinc -fno-builtin -m32 -I$(TOPDIR)/include \
                    -fno-stack-protector
export FROSK_LDFL = -T$(TOPDIR)/fbe_ldscript.ld -nostdlib -fno-builtin -m32 \
                    -fno-stack-protector $(TOPDIR)/lib/cstd.a $(TOPDIR)/lib/fapi.a

PRGMDIRS    = $(PRGMS_B:%=prgm/%)
PRGMS_PREF  = $(addprefix /,$(PRGMS_B))
PRGMS       = $(join $(PRGMDIRS), $(PRGMS_PREF))

UTILDIRS    = $(UTILS_B:%=util/%)
UTILS_PREF  = $(addprefix /,$(UTILS_B))
UTILS       = $(join $(UTILDIRS), $(UTILS_PREF))

DRVRDIRS    = $(DRVRS_B:%=drvr/%)
DRVRS_PREF  = $(addprefix /,$(DRVRS_B))
DRVRS_SUFF  = $(addsuffix .drvr,$(DRVRS_PREF))
DRVRS       = $(join $(DRVRDIRS), $(DRVRS_SUFF))

LIBFAPI     = lib/fapi.a
LIBCSTD     = lib/cstd.a


.PHONY: all
all: $(TARGET)

$(TARGET): bin bin/boot.bin bin/fs.bin
	cat bin/boot.bin bin/fs.bin > $(TARGET)

bin:
	mkdir bin

bin/boot.bin: boot/boot.asm
	nasm $^ -o $@

bin/fs.bin: bin/kernel.bin $(PRGMS) $(DRVRS) $(UTILS) default.f3s
	./util/f300-builder/f300-builder < default.f3s > $@

bin/kernel.bin: kernel/*
	nasm kernel/main.asm -o bin/kernel.bin

$(PRGMS): $(LIBFAPI) $(LIBCSTD) $(addsuffix /src/*,$(PRGMDIRS))
	$(MAKE) -C $(@D)

$(UTILS): $(addsuffix /src/*,$(UTILDIRS))
	$(MAKE) -C $(@D)

$(DRVRS): $(addsuffix /src/*,$(DRVRDIRS))
	$(MAKE) -C $(@D)

$(LIBFAPI) $(LIBCSTD): lib/fapi/src/* lib/cstd/src/*
	$(MAKE) -C lib 

.PHONY: clean
clean:
	-rm $(TARGET) bin/*
	-for DIR in $(PRGMDIRS); do $(MAKE) -C $$DIR clean; done
	-for DIR in $(UTILDIRS); do $(MAKE) -C $$DIR clean; done
	-for DIR in $(DRVRDIRS); do $(MAKE) -C $$DIR clean; done
	-$(MAKE) -C lib clean
	
