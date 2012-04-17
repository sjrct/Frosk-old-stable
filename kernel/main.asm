;
; main.asm
;
; written by sjrct
;

%include "kernel/def.asm"

[bits 32]
[org KERN_ORG]

main:
	mov byte [fs_drive], 0x0	; FIXME

	call kcls	; temporary
	
	call setup_paging
	call setup_phys_mem_mgr
	call setup_idt
	call setup_gdt
	call setup_kern_mem_mgr
	call setup_virt_mem_mgr
	call setup_f300
	call setup_drvrs
	call setup_tss

	; run start program
	push start_prgm
	call f300_locate_node
	push dword [eax + 8]
	call f300_resolve_entry_ptr

	mov ecx, [eax]
	shr ecx, 8
	shl ecx, 3
	push ecx
	mov eax, [eax + 8]	; Warning, ignores high dword
	shl eax, 3
	push eax
	mov al, [fs_drive]
	push eax
	push START_PRGM_MEM
	call ata_read_pio

	sti
	
	push 0
	push 0
	push PRIORITY_HIGH
	push 0
	push START_PRGM_MEM
	call create_process

	call setup_scheduler

.hltlp:
	hlt
	jmp .hltlp

%include "kernel/kio.asm"
%include "kernel/paging.asm"
%include "kernel/phys_mem.asm"
%include "kernel/idt.asm"
%include "kernel/gdt.asm"
%include "kernel/kern_mem.asm"
%include "kernel/virt_mem.asm"
%include "kernel/f300.asm"
%include "kernel/ata.asm"
%include "kernel/scheduler.asm"
%include "kernel/syscall.asm"
%include "kernel/drivers.asm"
%include "kernel/tss.asm"

%include "kernel/data.asm"
