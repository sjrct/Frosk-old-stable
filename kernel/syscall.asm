;
; syscall.asm
;
; written by sjrct
;

; syscall call interrupt handler (int 0x40)
;  eax = func id
syscall_int:
	push ecx
	push edx
	push ds
	push es
	push gs
	push ebx
	push ebp
	mov ebp, [esp + 40]
	sub ebp, 4

	mov dx, ss
	mov gs, dx
	mov dx, KERN_DS
	mov ds, dx
	mov es, dx

	mov ecx, [syscall_tbl + eax * 8 + 4]
	mov ebx, ecx
.push_loop:
	jecxz .push_loop_break
	push dword [ebp + ecx * 4]
	dec ecx
	jmp .push_loop
.push_loop_break:

	call [syscall_tbl + eax * 8]

	lea esp, [esp + ebx * 4]

	pop ebp
	pop ebx
	pop gs
	pop es
	pop ds
	pop edx
	pop ecx
	iret
