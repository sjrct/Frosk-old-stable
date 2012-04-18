;
; drivers.asm
;
; written by srjct
;
; drvr struct:
;   dd id
;   dw cs
;   dw ds
;   dd left
;   dd right
;
; drvr file:
;   dd mark
;   dword code section start
;   dword code section size
;   dword static data section start
;   dword static data section size;
;   dword driver number
;

;
setup_drvrs:
	ret


; interrupt handler for driver calls (int 0x41)
;  eax = function num, ecx = driver id
drvrcall_int:
	push ebp
	mov ebp, [esp + 16]
	sub ebp, 16
	push ecx
	push edx
	push ds
	push es
	push gs

	mov dx, ss
	mov gs, dx
	mov dx, KERN_DS
	mov ds, dx
	mov es, dx

	push eax
	push ecx
	call drvr_exists
	add esp, 4
	jecxz .ret_here
	
	xor ecx, ecx
	mov cx, [eax + 4]
	mov dx, [eax + 6]
	mov ds, dx
	mov es, dx
	
	push cs
	push .ret_here
	
	push ecx
	push dword 0

	mov eax, [esp + 16]
	retf
.ret_here:
	add esp, 4
	pop gs
	pop es
	pop ds
	pop edx
	pop ecx
	pop ebp
	iret


; helper function for drvr_exists
;  drvr_exists_h(head, id)
drvr_exists_h:
	mov eax, [esp + 4]
	mov edx, [esp + 8]

	cmp edx, [eax]
	je .found
	jb .left
	mov eax, [eax + 12]
	jmp .right
.left:
	mov eax, [eax + 8]
.right:
	test eax, eax
	jz .found

	push edx
	push eax
	call drvr_exists_h
	add esp, 8
.found:
	ret


; returns the pointer to the driver
;  drvr_exists(id)
drvr_exists:
	mov ecx, [esp + 4]
	mov eax, [drvr_tree_head]
	test eax, eax
	jz .return

	cmp ecx, [eax]
	je .return

	push ecx
	push eax
	call drvr_exists_h
	add esp, 8
.return:
	ret


; should pass head of the tree into the function
; returns ptr if is successful, 0 if not
;  add_new_drvr(head, id)
add_new_drvr:
	push ebx

	mov ecx, [esp + 8]
	mov edx, [esp + 12]
	
	cmp edx, [ecx]
	je .return0
	jb .left
	mov ebx, 12
	jmp .right
.left:
	mov ebx, 8
.right:

	add ebx, ecx
	cmp dword [ebx], 0
	je .found
	
	push edx
	push ebx
	add esp, 8
	jmp .return
.found:
	call kalloc_16
	
	mov [ebx], eax
	mov ecx, [esp + 12]
	mov [eax], ecx
	mov dword [eax + 8], 0
	mov dword [eax + 12], 0

.return:
	pop ebx
	ret
.return0:
	xor eax, eax
	jmp .return


; the buffer should be in the drvr file format
;  create_drvr(buf)
create_drvr:
	push ebx
	push esi
	push edi

	mov ebx, [esp + 16]
	; TODO test mark

	mov eax, [gs:ebx + 20]
	test eax, eax
	jz .return
	
	; create base structure for driver, return if cant
	mov eax, [drvr_tree_head]
	test eax, eax
	jz .null
	
	push dword [gs:ebx + 20]
	push eax
	call add_new_drvr
	add esp, 8	
	jmp .not_null
.null:
	
	call kalloc_16
	mov [drvr_tree_head], eax
	mov ecx, [gs:ebx + 20]
	mov [eax], ecx
	mov dword [eax + 8], 0
	mov dword [eax + 12], 0
.not_null:

	test eax, eax
	jz .return
	mov edi, eax

	; allocate memory for code and create code segment
	mov ecx, [gs:ebx + 8]
	test ecx, 0xfff
	jz .no_align
	and ecx, ~0xfff
	add ecx, 0x1000
.no_align:
	push ecx
	call alloc_virt_pgs
	pop ecx

	shr ecx, 12
	push 0x9ac0
	push ecx
	push eax
	call add_gdt_entry
	pop ecx
	add esp, 8
	mov [edi + 4], ax

	; copy code to cs
	push edi
	push ds

	mov edi, ecx

	mov ax, gs
	mov ds, ax
	
	cld
	mov esi, [gs:ebx + 4]
	add esi, ebx
	mov ecx, [gs:ebx + 8]
	rep movsb
	pop ds
	pop edi
	
	; allocate data mem and create ds
	mov ecx, [gs:ebx + 0x10]
	test ecx, 0xfff
	jz .no_align2
	and ecx, ~0xfff
	add ecx, 0x1000
.no_align2:
	push ecx
	call alloc_virt_pgs
	pop ecx

	shr ecx, 12
	push 0x92c0
	push ecx
	push eax
	call add_gdt_entry
	pop ecx
	add esp, 8
	mov [edi + 6], ax
	
	; copy data to ds
	push edi
	push ds

	mov edi, ecx

	mov ax, gs
	mov ds, ax
	
	cld
	mov esi, [gs:ebx + 0xc]
	add esi, ebx
	mov ecx, [gs:ebx + 0x10]
	rep movsb
	
	pop ds
	pop edi
	
	mov eax, [gs:ebx + 20]
.return:
	pop edi
	pop esi
	pop ebx
	ret
