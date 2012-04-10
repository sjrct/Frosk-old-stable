;
; idt.asm
;
; written by sjrct
;

setup_idt:
	cli

	; set the idt pointer
	mov dword [idt_ptr + 2], IDT_LOC
	mov word [idt_ptr], 0x800

	; initialize idt to default values
	mov ecx, 0xf8
	mov si, KERN_CS
	mov bl, 0x8e
.def_loop:
	mov eax, ecx
	mov edx, default_int_handler
	call set_idt_entry
	loop .def_loop

	; interrupt gates
	mov edx, page_fault
	mov eax, 0xe
	call set_idt_entry
	
	mov edx, gpf
	mov eax, 0xd
	call set_idt_entry
	
	; trap gates
	mov bl, 0x8f
	mov edx, timer_int
	mov eax, 0x20
	call set_idt_entry
	
	mov edx, syscall_int
	mov eax, 0x40
	call set_idt_entry
	
	mov edx, drvrcall_int
	mov eax, 0x41
	call set_idt_entry
	
	call setup_pic
	lidt [idt_ptr]
	ret


; temporary	
gpf:
	mov ax, KERN_DS
	mov ds, ax
	mov es, ax
	mov gs, ax
	call kputh
	call knewline
	push gpf_msg
	call kputs
	jmp $
gpf_msg: db 'gpf', 0


; arguments: idt_entry_num=eax, func=edx, selector=si, flags=bl
; ecx preserved
set_idt_entry:
	shl eax, 3
	add eax, IDT_LOC
	mov [eax], dx
	shr edx, 16
	mov [eax + 6], dx
	mov [eax + 2], si
	mov byte [eax + 4], 0
	mov [eax + 5], bl
	ret
	
	
; wrapper for system calls to set_idt_entry
set_idt_entry_wrap:
	push esi
	push ebx
	mov eax, [esp + 12]
	mov edx, [esp + 16]
	mov esi, [esp + 20]
	mov ebx, [esp + 24]
	call set_idt_entry
	pop ebx
	pop esi
	ret
	

; sets up the programmable interrupt controller	
setup_pic:
	; ICW1
	mov al, 0x11
	out 0x20, al
	io_wait
	out 0xa0, al
	io_wait
	
	; ICW2, IRQ int offset
	mov al, 0x20	; IRQ 0-7 at int 0x20-0x27
	out 0x21, al
	io_wait
	
	mov al, 0x28
	out 0xa1, al	; IRQ 8-0xf at int 0x28-0x2f
	io_wait
	
	; ICW3, master/slave wiring
	mov al, 4
	out 0x21, al
	io_wait
	
	mov al, 2
	out 0xa1, al
	io_wait
	
	; ICW4, set environment data
	mov al, 1	; 8086 mode
	out 0x21, al
	io_wait
	out 0xa1, al
	io_wait
	
	; mask interrupts
	mov al, PIC_MASTER_MASK
	out 0x21, al
	mov al, PIC_SLAVE_MASK
	out 0xa1, al
	
	ret
	
	
;  the default interrupt handler
default_int_handler:
	mov ax, KERN_DS
	mov ds, ax
	mov es, ax
	mov gs, ax

	call knewline
	push dih_msg
	call kputs
	jmp $
	iret
	
dih_msg:
	db 'unregistered interrupt', 0
