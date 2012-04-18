;
; scheduler-new.asm
;
; written by sjrct
;
; process structure:
;   word cs
;   word ds/ss (ring 0)
;   word ds/ss (ring 3)
;   word 
;   dword extra data ptr
;   dword next
;
; process extra structure:
;   dword code virt offset
;   dword code section size
;   dword data virt offset
;   dword data (heap/stack) section size 
;
; thread structure:
;   byte status
;   byte [kern_stack_high, 4 bits][priority, 4 bits]
;   word kern_stack_low (* page_size)
;   dword esp
;   dword proc handle
;   dword next
;
; fbe file format:
;   dword 0xfbe0fbe0
;   dword code section start
;   dword code section size
;   dword static data section start
;   dword static data section size
;
; TODO: cleanup this file
;

; sets up scheduling
setup_scheduler:
	; setup teh timer
	mov al, 0x30	; interrupt on terminal count mode
	out 0x43, al
	mov al, 1
	out 0x40, al
	xor al, al
	out 0x40, al
	ret
	
	
; called when the PIT sends an IRQ0
; handles task switching
timer_int:
	push eax
	push ebx
	push ecx
	push ds
	
	mov ax, KERN_DS
	mov ds, ax
	
	; check if no tasks
	xor eax, eax
	mov ecx, [first_thread]
	test ecx, ecx
	jz .return_early
	
	; get next task
	; TODO: check for idle priority
	mov ebx, ecx
.search_loop:
	cmp byte [ecx], STATUS_READY
	je .search_loop_break

	mov ecx, [ecx + 12]
	cmp ecx, ebx
	je .return_early
	jmp .search_loop
.search_loop_break:
	mov eax, [ecx + 12]
	mov [first_thread], eax
	
	; reset the timer
	xor al, al
	out 0x40, al
	mov bl, 0x10

	mov al, 0x20
	out 0x20, al

	; save remaining old context
	push edx
	push esi
	push edi
	push ebp
	push es
	push fs
	push gs

	pushf
	push cs
	push .return_here
	
	mov eax, [current_thread]
	test eax, eax
	jz .ct_null
	mov [eax + 4], esp
.ct_null:
	mov [current_thread], ecx

	; get new stack
	mov edx, [ecx + 8]
	mov esp, [ecx + 4]
	mov ss, [edx + 2]
	mov [TSS_SEG_LOC + 8], ss
	
	mov al, [ecx + 1]
	and al, 0xf0
	shl eax, 12
	or ax, [ecx + 2]
	shl eax, 12
	mov [TSS_SEG_LOC + 4], eax

	; flush tlb, TODO: optimize
	mov eax, cr3
	mov cr3, eax

	; goto new thread
	mov al, bl
	out 0x40, al
	iret
.return_here:

	; restore old context
	pop gs
	pop fs
	pop es
	pop ebp
	pop edi
	pop esi
	pop edx

.return:
	pop ds
	pop ecx
	pop ebx
	pop eax
	iret
.return_early:
	xor al, al
	out 0x40, al
	out 0x40, al	
	mov al, 0x20
	out 0x20, al
	jmp .return


; creates new process w/ 1 thread, returns process handle (0 if failed)
;  create_process(buffer, cwd, priority, argc, argv)
create_process:
	push ebx
	push esi
	push edi

	; check that buffer is valid
	mov ebx, [esp + 16]
	cmp dword [gs:ebx], 0xfbe0fbe0
	jne .return_zero

	; alloc process structures and add to list
	call kalloc_16
	mov edi, eax
	call kalloc_16
	mov esi, eax
	shr esi, 4
	and esi, 7
	mov ecx, [process_lists + esi * 4]
	mov [eax + 8], edi
	jcxz .fp_null
	mov edx, [ecx + 12]
	mov [ecx + 12], eax
	mov [eax + 12], edx
	jmp .fp_not_null
.fp_null:
	mov [process_lists + esi * 4], eax
	mov [eax + 12], eax
.fp_not_null:
	mov esi, eax
	
	; alloc virt code pages
	mov ecx, [gs:ebx + 8]
	test ecx, 0xfff
	jz .no_align
	and ecx, ~0xfff
	add ecx, 0x1000
.no_align:
	mov [edi + 4], ecx
	push ecx
	call alloc_virt_pgs
	pop ecx
	mov [edi], eax
	
	; create CS
	shr ecx, 12
	push 0xfac0
	push ecx
	push eax
	call add_gdt_entry
	pop edx
	mov [esi], ax
	or word [esi], 3
	add esp, 8

	push esi
	pushf
	push edi
	push ds

	; copy setup code
	cld
	mov esi, setup_code
	mov edi, edx		
	mov ecx, setup_code.end - setup_code
	rep movsb

	; copy user code
	mov ax, gs
	mov ds, ax

	mov esi, [gs:ebx + 4]
	add esi, ebx
	mov ecx, [gs:ebx + 8]
	rep movsb

	pop ds
	mov edi, [esp]

	; TODO: fix so default is only used when alternative not specified
	; alloc virt data pages
	mov dword [edi + 12], DEF_HS_SPREAD + 0x1000
	push DEF_HS_SPREAD + 0x1000
	call alloc_virt_pgs
	mov [edi + 8], eax
	add esp, 4

	; copy cwd
	mov ecx, [esp + 32]
	mov [eax + 8], ecx

	; 
	mov edx, DEF_HS_SPREAD - 0x2000
	sub edx, ecx
	mov [eax + 16], edx
		
	push eax
	push ds
	
	; copy globals over
	lea edi, [eax + 0x14]
	mov ax, gs
	mov ds, ax
	mov esi, [gs:ebx + 12]
	add esi, ebx
	mov ecx, [gs:ebx + 16]
	rep movsb

	pop ds
	mov eax, [esp]	
	push ebx

	; copy args
	mov edx, [esp + 48]	; argc
	mov esi, [esp + 52] ; argv
	
	mov ecx, edi
	lea edi, [ecx + edx * 4]
	jmp .args_loop_check
.args_loop:
	mov ebx, [gs:esi]
	sub edi, eax
	mov [ecx], edi
	add edi, eax
.arg_str_loop:
	mov al, [gs:ebx]
	mov [edi], al
	inc edi
	test al, al
	jz .arg_str_loop_break
	inc ebx
	jmp .arg_str_loop
.arg_str_loop_break:
	add esi, 4
	add ecx, 4
	dec edx
.args_loop_check:
	test edx, edx
	jnz .args_loop

	pop ebx
	pop eax

	; set location of heap
	sub edi, eax
	mov [eax + 12], edi

	pop edi
	popf
	pop esi
	
	; setup stack
	mov ecx, DEF_HS_SPREAD - 4
	add ecx, eax

	mov dword [ecx], KERN_CS
	mov dword [ecx - 4], proc_finish
	mov edx, [gs:ebx + 16]
	add edx, 0x14
	mov dword [ecx - 8], edx
	mov edx, [esp + 28]
	mov dword [ecx - 12], edx
	mov dword [ecx - 24], DEF_HS_SPREAD - 20
	pushf
	mov edx, [esp]
	add esp, 4
	mov [ecx - 28], edx

	xor edx, edx
	mov dx, [esi]
	mov [ecx - 32], edx
	mov dword [ecx - 36], 0
		
	; prep for stack underflow
	push ecx
	add ecx, 0x1000
	mov dword [ecx], 0
	and ecx, ~0xfff
	shr ecx, 10
	mov edx, [PAGE_TABLES_LOC + ecx]
	and edx, ~2
	mov [PAGE_TABLES_LOC + ecx], edx	
	pop ecx

	; create DSs	
	push ecx

	push 0xf2c0
	push DEF_HS_SPREAD / 0x1000 + 1
	push eax
	call add_gdt_entry
	or ax, 3
	mov [esi + 4], ax
	and eax, 0xffff
	mov ecx, [esp + 12]
	mov [ecx - 16], eax
	mov [ecx - 20], eax
	pop eax
	add esp, 8

	push 0x92c0
	push DEF_HS_SPREAD / 0x1000 + 1
	push eax
	call add_gdt_entry
	mov [esi + 2], ax
	pop edx
	add esp, 8

	pop ecx
	
	; alloc mem for thread structure
	call kalloc_16
	
	; setup thread structure
	mov byte [eax], STATUS_SETUP
	mov ecx, [esp + 24]
	or cl, (((DEF_HS_SPREAD + 0x1000) >> 24) & 0xf0)
	mov [eax + 1], cl
	mov word [eax + 2], ((DEF_HS_SPREAD + 0x1000) >> 12) & 0xffff
	mov dword [eax + 4], DEF_HS_SPREAD - 40
	mov [eax + 8], esi
	
	; add to linked list
	mov ecx, [first_thread]
	jecxz .ft_null
	mov edx, [ecx + 12]
	mov [ecx + 12], eax
	mov [eax + 12], edx
	jmp .ft_not_null
.ft_null:
	mov [first_thread], eax
	mov [eax + 12], eax
.ft_not_null:
	mov byte [eax], STATUS_READY

.return:
	pop edi
	pop esi
	pop ebx
	ret
.return_zero:
	xor eax, eax
	jmp .return


; the setup code that goes before all the user specified code
setup_code:
	pop eax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	call .end
	add esp, 8
	mov eax, 13
	int 0x40
	times 0x20 - ($ - setup_code) db 0
.end:


; this function is syscall, eax = 13, used automatically when process dies
proc_finish:
	mov ax, ds
	mov gs, ax
	mov ax, KERN_DS
	mov ds, ax
	mov eax, [current_thread]
	
	mov ebx, eax
.loop:
	mov ecx, [eax + 12]
	cmp ebx, ecx
	je .break
	mov eax, ecx
	jmp .loop
.break:

	mov ecx, [ebx + 12]
	mov [eax + 12], ecx

	; free process data if last thread
	push dword [first_thread]
	push dword [ebx + 8]
	call locate_process_thread
	test eax, eax
	jnz .not_last_thread
	call free_process
.not_last_thread:
	; TODO free structure if detached

	mov byte [ebx], STATUS_DONE	

	mov al, 1
	out 0x40, al
	dec al
	out 0x40, al
	sti
.hltlp:
	hlt
	jmp .hltlp


; waits for a specified thread to finish
; wait_thread(id)
wait_thread:
	mov ecx, [esp + 4]
	mov al, [ecx]
	cmp al, STATUS_DONE
	je .break
.loop:
	hlt
	mov al, [ecx]
	cmp al, STATUS_DONE
	jne .loop
.break:
	push ecx
	call kfree_16
	add esp, 4
	ret


;  locate_process_thread(process_id, thread_start) 
locate_process_thread:
	mov edx, [esp + 4]
	mov ecx, [esp + 8]
	mov eax, ecx
.loop:
	cmp edx, [eax + 8]
	je .break
	mov eax, [eax + 12]
	cmp eax, ecx
	jne .loop
	xor eax, eax
.break:
	ret


; frees kernel 16-byte structures, and gdt entries
; TODO free pages
;  free_process(proc_id)
free_process:
	mov ecx, [esp + 4]
	xor eax, eax
	mov ax, [ecx]
	push eax
	mov ax, [ecx + 2]
	push eax
	mov ax, [ecx + 4]
	push eax
	push dword [ecx + 8]
	push ecx
	call kfree_16
	add esp, 4
	call kfree_16
	add esp, 4
	call remove_gdt_entry
	add esp, 4
	call remove_gdt_entry
	add esp, 4
	call remove_gdt_entry
	add esp, 4
	ret

