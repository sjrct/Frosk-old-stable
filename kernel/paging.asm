;
; paging.asm
;
; written by sjrct
;

; set up the page directory, and first 2 page tables
setup_paging:
	; zero unused pdt and pt entries
	cld
	xor eax, eax
	mov ecx, 1022
	mov edi, PAGE_DIR_LOC + 8
	rep stosd
	mov ecx, 1022
	mov edi, PAGE_TBL1_LOC + 8
	rep stosd
	mov ecx, 768
	mov edi, PAGE_TBL0_LOC + 0x400
	rep stosd
	
	; identity page low MiB
	mov ecx, 0x100
	mov eax, 0x100003
.ident_loop:
	dec ecx
	sub eax, 0x1000
	mov [PAGE_TBL0_LOC + ecx * 4], eax
	test ecx, ecx
	jnz .ident_loop
	
	; setup page dir and page table 2
	mov dword [PAGE_DIR_LOC],      PAGE_TBL0_LOC | 0x3
	mov dword [PAGE_DIR_LOC + 4],  PAGE_TBL1_LOC | 0x3
	mov dword [PAGE_TBL1_LOC],     PAGE_TBL0_LOC | 0x3
	mov dword [PAGE_TBL1_LOC + 4], PAGE_TBL1_LOC | 0x3

	; enable paging
	mov eax, PAGE_DIR_LOC
	mov cr3, eax
	mov eax, cr0
	or eax, 0x80000000
	mov cr0, eax
		
	ret
	
	
; interrupt handler for page faults
; handles making sure that pages are in memory when referenced
page_fault:
	push eax
	push ecx
	push edx
	push gs
	pushf

	mov ax, KERN_DS
	mov gs, ax
	
	; check if something not present or protection fault
	mov eax, [esp + 16]
	test eax, 1
	jz .not_present
	
	; page protection fault (stack underflow)
	push 0x1337c0de
	call kputh
	jmp $
	
.not_present:

	; get pte and pdte
	mov edx, cr2
	mov ecx, edx
	shr edx, 20
	shr ecx, 10
	and ecx, 0xffc
	and edx, ~0x3
	
	test byte [gs:PAGE_DIR_LOC + edx], 1
	jnz .page_not_present
	
	; create new pt and zero all entries
	push es
	push edi
	push ecx
	push edx

	mov di, gs
	mov es, di

	call get_free_phys_page
	pop edx
	add eax, 0xf
	mov [gs:PAGE_DIR_LOC + edx], eax
	mov [gs:PAGE_TABLES_LOC + 0x1000 + edx], eax
	
	cld
	shl edx, 10
	lea edi, [PAGE_TABLES_LOC + edx]
	xor eax, eax
	mov ecx, 0x400
	rep stosd

	pop ecx
	pop edi
	pop es
	jmp .tbl_not_present
.page_not_present:
	shl edx, 10
.tbl_not_present:
	
	; create new pg
	push ecx
	push edx
	call get_free_phys_page
	pop edx
	pop ecx
	or eax, 0x7

	mov [gs:PAGE_TABLES_LOC + edx + ecx], eax

	popf
	pop gs
	pop edx
	pop ecx
	pop eax
	add esp, 4
	
	iret
	
	
; takes a virtual page address and frees the physical page associated with it
; it returns the physical page address
free_page:
	; remove the virtual page
	mov ecx, [esp + 4]
	shr ecx, 12
	add ecx, PAGE_TABLES_LOC
	mov eax, [ecx]
	and eax, ~0xfff
	mov dword [ecx], 0

	; set the physical page to unused
	mov edx, eax
	shr edx, 12
	mov ecx, edx
	and ecx, 0xfff
	shr edx, 3
	add edx, MEM_BITMAP_LOC
	bts [edx], ecx

	ret
