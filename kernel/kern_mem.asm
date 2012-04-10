;
; kern_mem.asm
;
; written by sjrct
;

setup_kern_mem_mgr:
	xor eax, eax
	mov edi, KERN_MEM_LOC
	mov ecx, 8
	rep stosd
	mov byte [KERN_MEM_LOC], 3
	ret


; gets a pointer to kernel memory that is 16 bytes in size
kalloc_16:
	push ebx

	; search for a free section of 16 bytes
	mov eax, [next_kmem_byte]
	and eax, ~0x3
	mov ebx, eax
	mov edx, [kmem_max]
.search_loop:
	cmp dword [eax], 0xffffffff
	je .search_loop_next
	
	xor ecx, ecx
.byte_search_loop:
	cmp byte [eax], 0xff
	jne .byte_search_loop_break
	inc eax
	add ecx, 8
	cmp ecx, 32
	jne .byte_search_loop
	and eax, ~0x3
	jmp .search_loop_next
.byte_search_loop_break:
	xor ecx, ecx
.bit_search_loop:
	bts [eax], ecx
	jnc .found
	inc ecx
	test ecx, 0x8
	jz .bit_search_loop

.search_loop_next:
	add eax, 4
	test eax, 0x20
	jz .no_page_change
	cmp eax, edx
	jne .no_reset
	mov eax, KERN_MEM_LOC
	jmp .no_page_change
.no_reset:
	add eax, 0xfe0
.no_page_change:
	cmp eax, ebx
	jne .search_loop
	
	; add another page and return
	push edi
	pushf

	cld
	add edx, 0x1000
	mov [kmem_max], edx
	lea edi, [edx - 0x1c]
	mov ecx, 7
	xor eax, eax
	rep stosd
	lea eax, [edi - 0x20]
	mov dword [eax], 7
	inc ecx

	popf
	pop edi

.found:
	mov [next_kmem_byte], eax
	mov edx, eax
	and edx, 0x1f
	and eax, ~0x1f
	shl edx, 7
	shl ecx, 4
	add eax, ecx
	add eax, edx
	
	pop ebx
	ret
	
	
; frees a 16 byte block of kernel memory
kfree_16:
	mov eax, [esp + 4]
	mov ecx, eax
	and ecx, 0xff0
	and eax, ~0xfff
	mov edx, ecx
	shr ecx, 7
	add eax, ecx
	shr edx, 4
	and edx, 0x7
	btr [eax], edx
	ret
