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
	push ebp
	mov ebp, esp
	
	mov dx, ds
	mov gs, dx
	mov dx, KERN_DS
	mov ds, dx
	mov es, dx

	mov ecx, [syscall_tbl + eax * 8 + 4]
.push_loop:
	jecxz .push_loop_break
	push dword [ebp + 0x20 + ecx * 4]
	dec ecx
	jmp .push_loop
.push_loop_break:

	call [syscall_tbl + eax * 8]
	
	mov esp, ebp
	pop ebp
	pop gs
	pop es
	pop ds
	pop edx
	pop ecx
	iret
