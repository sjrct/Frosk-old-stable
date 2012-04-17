;
; tss.asm
;
; written by sjrct
;

; creates & loads a tss
setup_tss:
	mov dword [TSS_SEG_LOC + 4], KERN_STACK
	mov dword [TSS_SEG_LOC + 8], KERN_DS
	mov dword [TSS_SEG_LOC + 0x64], 0x68
	
	push 0x8940
	push 0x68
	push TSS_SEG_LOC
	call add_gdt_entry
	add esp, 12
	
	ltr ax
	ret

