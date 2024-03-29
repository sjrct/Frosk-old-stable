;
; data.asm
;
; written by sjrct
;

align 4

; dwords for allocation
next_phys_bitmap_byte: dd MEM_BITMAP_LOC
first_free_gdte: dd GDT_LOC
next_kmem_byte: dd KERN_MEM_LOC
kmem_max: dd KERN_MEM_LOC + 0x20
virt_mem_head: dd 0

; dwords for task managment
first_process: dd 0
first_thread:  dd 0
current_thread: dd 0

process_lists:
	times 8 dd 0

; dwords for driver managment
drvr_tree_head: dd 0

; table of system calls
;  entry: [dword function_ptr][dword arg count]
syscall_tbl:
	dd f300_locate_node	; 0
	dd 1
	dd f300_copy_node
	dd 2
	dd f300_resolve_entry_ptr
	dd 1
	dd create_process
	dd 5
	dd drvr_exists
	dd 1
	dd wait_thread		; 5
	dd 1
	dd f300_find_first
	dd 1
	dd f300_find_next
	dd 1
	dd f300_add_node
	dd 3
	dd proc_finish
	dd 0
	dd f300_get_drive	; 10
	dd 0
	dd kputh
	dd 1
	dd kputs
	dd 1

priv_syscall_tbl:
	dd set_idt_entry_wrap	; 0
	dd 4
	dd ata_read_pio
	dd 4
	dd ata_write_pio
	dd 4
	dd create_drvr
	dd 1

; table of ata i/o ports bases
ata_port_bases:
	dw 0x1f0
	dw 0x3f0
	dw 0x170
	dw 0x370
	dw 0x1e8
	dw 0x3e0
	dw 0x168
	dw 0x360

; for the file system
first_fs_blocks: dd 0

fs_drive: db 0

; table pointers
db 0 ; align
gdt_ptr: dw 0, 0, 0
dw 0
idt_ptr: dw 0, 0, 0

; strings
start_prgm: db '!sys/prgm/start', 0
