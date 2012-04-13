;
; virt_mem.asm
;
; written by sjrct
;

; sets up the virt page memory manager
setup_virt_mem_mgr:
	call kalloc_16
	mov [eax + 8], eax
	mov [eax + 12], eax
	mov dword [eax], 0xfe000000
	mov dword [eax + 4], 0x2000000
	mov [virt_mem_head], eax
	ret


; allocate virtual pages of a given length
;  alloc_virt_pgs(pages*0x1000)
alloc_virt_pgs:
	; search for a suitable block of pages
	mov eax, [virt_mem_head]
	test eax, eax
	jz .return
	mov ecx, [esp + 4]
	mov edx, eax
.search_loop:
	cmp ecx, [eax]
	jbe .found
	mov eax, [eax + 8]
	cmp eax, edx
	jne .search_loop
	; TODO: PANIC!
	push 0x1eaf1ead
	call kputh
	jmp $
.found:

	cmp ecx, [eax]
	jne .not_exact

	; found exact block
	cmp eax, [eax + 8]
	jne .not_last
	mov dword [virt_mem_head], 0
	jmp .last
.not_last:
	mov ecx, [eax + 12]
	mov edx, [eax + 8]
	mov [ecx + 8], edx
	mov ecx, [eax + 8]
	mov edx, [eax + 12]
	mov [ecx + 12], edx
.last:
	push dword [eax + 4]
	push eax
	call kfree_16
	add esp, 4
	pop eax
	jmp .return

.not_exact:
	; found not exact block
	mov edx, [eax]
	sub edx, ecx
	mov [eax], edx
	mov edx, [eax + 4]
	add edx, ecx
	xchg [eax + 4], edx
	mov eax, edx
.return:
	ret


;
free_virt_pgs:
	; TODO
	ret
