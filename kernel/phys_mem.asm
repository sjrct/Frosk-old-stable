;
; phys_mem.asm
;
; written by sjrct
;

;
setup_phys_mem_mgr:
	; initialize all physical memory to used
	mov ecx, 0x8000
	mov edi, MEM_BITMAP_LOC
	mov eax, 0xffffffff
	rep stosd

	; find usable memory 
	xor ecx, ecx
	mov cx, [MEM_MAP_LOC]
	mov eax, MEM_MAP_LOC + 8
.mem_find_loop:
	cmp dword [eax + 16], 1
	jne .mem_find_loop_next
	cmp dword [eax + 4], 0
	jne .mem_find_loop_next
	mov ebx, [eax]
	test ebx, ebx
	jz .mem_find_loop_next

	mov edx, [eax + 8]	
	test ebx, 0xfff
	jz .no_align
	mov esi, ebx
	and esi, 0xfff
	sub ebx, esi
	add ebx, 0x1000
	sub edx, esi	
.no_align:
	and edx, 0xfffff000
	
	mov esi, ebx
	shr ebx, 15
	add ebx, MEM_BITMAP_LOC
	shr esi, 12
	and esi, 7
	
.set_loop:
	btr [ebx], esi
	sub edx, 0x1000
	test edx, edx
	jz .mem_find_loop_next
	inc esi
	cmp esi, 8
	jne .set_loop
	xor esi, esi
	inc ebx
	jmp .set_loop

.mem_find_loop_next:
	add eax, 24
	cmp eax, ecx
	jne .mem_find_loop

	ret


; searches the bitmap for a free physical page, sets to used and returns addr
; TODO if no free phys pg, free page and return that
get_free_phys_page:
	push edi

	mov eax, [gs:next_phys_bitmap_byte]
	mov edi, eax
.search_loop:
	mov ecx, [gs:eax]
	cmp ecx, 0xffffffff
	je .search_loop_next
	
	xor edx, edx
.byte_search_loop:
	cmp cl, 0xff
	jne .bit_search_loop
	add edx, 8
	shr ecx, 8
	cmp edx, 32
	jne .byte_search_loop
	jmp .search_loop_next
.bit_search_loop:
	test ecx, 1
	je .search_loop_break
.search_loop_resume:
	shr ecx, 1
	inc edx
	test edx, 8
	jz .bit_search_loop
.search_loop_next:
	add eax, 4
	
	cmp eax, edi
	je .nothing_left
	
	cmp eax, MEM_BITMAP_LOC + 0x20000
	jne .search_loop
	mov eax, MEM_BITMAP_LOC
	jmp .search_loop
.nothing_left:
	push 0xb00bbeef
	call kputh
	jmp $
	; TODO handle no pages left
	xor eax, eax
.search_loop_break:

	bts [gs:eax], edx
	jc .search_loop_resume
	
	mov [gs:next_phys_bitmap_byte], eax

	sub eax, MEM_BITMAP_LOC
	shl eax, 15
	shl edx, 12
	add eax, edx
	
	pop edi
	ret
