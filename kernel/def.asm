;
; def.asm
;
; written by sjrct
;

; memory locations
%define MEM_MAP_LOC     0xc00
%define FST_LOC         0x1000
%define BOOT_ORG        0x7C00
%define KERN_ORG        0x7E00
%define MEM_BITMAP_LOC  0x20000
%define PAGE_DIR_LOC    0x40000
%define PAGE_TBL0_LOC   0x41000
%define PAGE_TBL1_LOC   0x42000
%define IDT_LOC         0x43000
%define GDT_LOC         0x43800
%define TSS_SEG_LOC     0x44000
%define START_PRGM_MEM  0x44100
%define KERN_STACK      0x80000
%define KERN_MEM_LOC    0x100000
%define PAGE_TABLES_LOC 0x400000

; default values
%define DEF_HS_SPREAD   0x100000

; enums
%define STATUS_SETUP    0
%define STATUS_READY    1
%define STATUS_RUNNING  2
%define STATUS_DONE     3

%define PRIORITY_IDLE   0
%define PRIORITY_LOW    1
%define PRIORITY_NORMAL 2
%define PRIORITY_HIGH   3
%define PRIORITY_AYP    4

; segments
%define KERN_CS         0x8
%define KERN_DS         0x10

; masks
%define PIC_MASTER_MASK 0xFC
%define PIC_SLAVE_MASK  0xFF

; operations
%define io_wait out 0x80,al
