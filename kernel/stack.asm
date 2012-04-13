;
; stack.asm
;
; written by sjrct
;


; sets up tss for stack handling
setup_stack_handling:
	push 0x8940
	push 0x68	
	push STACK_SEG_TSS
	call add_gdt_entry
	add esp, 12
	
	mov si, ax
	mov eax, 11
	xor edx, edx
	mov bl, 0x8e
	call set_idt_entry
	
	mov dword [STACK_SEG_TSS + 4], STACK_SEG_STACK
	mov word [STACK_SEG_TSS + 0x8], KERN_DS
	mov eax, cr3
	mov [STACK_SEG_TSS + 0x1c], eax
	mov dword [STACK_SEG_TSS + 0x20], stack_fault
	mov word [STACK_SEG_TSS + 0x4c], KERN_CS
	
	ret


; handles stack overflow, resizes the stack and causes page fault
stack_fault:
	jmp $
	push eax
	push ebx
	push ecx
	push edx
	push ds
	
	mov ax, KERN_DS
	mov ds, ax
	
	mov eax, [esp + 0x14]
	and eax, 0xfff8
	add eax, GDT_LOC
	
	mov cl, [eax + 6]
	and ecx, 0xf
	shl ecx, 16
	mov cx, [eax]

	sub ecx, 0x1000
	mov edx, ecx
	
	mov [eax], cx
	shr ecx, 16
	mov bl, [eax + 6]
	and bl, 0xf0
	or cl, bl
	mov [eax + 6], cl

	lgdt [gdt_ptr]
	
	sub eax, GDT_LOC
	mov ds, ax
	mov [ds:ecx], ecx
	
	pop ds
	pop edx
	pop ecx
	pop ebx
	pop eax
	add esp, 4
	iret
