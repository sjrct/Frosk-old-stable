;
; f300.asm
;
; written by sjrct
;

; setup the f300 file system table
setup_f300:
	call kalloc_16
	mov dword [eax], FST_LOC
	mov dword [eax + 12], 0
	mov [first_fs_blocks], eax
	
	; TODO check if meta blocks 2 & 3 exist and load if yes
	
	ret


; resolves pointers (these r stored on disk)
; pointer: [24 bits for block][8 bits for entry]
f300_resolve_entry_ptr:
	; seach for block
	mov ecx, [esp + 4]
	mov edx, ecx
	shr ecx, 8
	mov eax, [first_fs_blocks]
.block_search:
	cmp ecx, 3
	jl .block_search_break
	cmp dword [eax + 12], 0
	jne .not_null
	; TODO 
.not_null:
	sub ecx, 3
	mov eax, [eax + 12]

	jmp .block_search
.block_search_break:
	
	; if block[n] is null then invalid pointer, return 0
	mov eax, [eax + ecx * 4]
	test eax, eax
	jz .return
	
	; resolve entry num to entry offset and add to block location
	and edx, 0xff
	shl edx, 4
	add eax, edx
.return:
	ret


; helper function for f300_locate_node
f300_locate_node_h:
	push ebx
	push edi

	; search given branch for correct name
	mov ebx, [esp + 12]

.search_loop:
	push dword [ebx + 4]
	call f300_resolve_entry_ptr
	add esp, 4
	add eax, 2
	mov edi, [esp + 16]
.str_check_loop:
	mov cl, [eax]
	mov ch, [gs:edi]

	cmp ch, '/'
	je .slash
	cmp cl, ch
	jne .next
	
	inc eax
	inc edi

	test cl, cl
	jnz .str_check_loop
	
	mov eax, ebx
	jmp .break
	
.slash:
	test cl, cl
	jnz .next
	
	inc edi
	push edi
	mov eax, [ebx + 8]
	push eax
	call f300_resolve_entry_ptr
	mov [esp], eax
	call f300_locate_node_h
	add esp, 8
	jmp .break
	
.next:
	mov ebx, [ebx + 12]
	test ebx, ebx
	jz .nothing_found
	push ebx
	call f300_resolve_entry_ptr
	add esp, 4
	mov ebx, eax
	jmp .search_loop	
.nothing_found:
	xor eax, eax
.break:
	
	pop edi
	pop ebx
	ret
	
	
; resolve relative/absolute paths (relative paths dont work in kernel land)
;  f300_locate_node(fn*)
f300_locate_node:
	mov ecx, [esp + 4]
	
	cmp byte [gs:ecx], '!'
	jne .relative
	
	mov eax, [first_fs_blocks]
	mov eax, [eax]
	mov eax, [eax + 0x14]

	push ecx
	push eax
	call f300_resolve_entry_ptr
	add esp, 4
	pop ecx
	
	inc ecx
	cmp byte [gs:ecx], 0
	je .return
	
	push ecx
	push dword [eax + 8]
	call f300_resolve_entry_ptr
	mov [esp], eax
	call f300_locate_node_h
	jmp .return8
.relative:
	
	push ecx
	mov eax, [gs:8] ; current branch
	push dword [eax + 8]
	call f300_resolve_entry_ptr
	mov [esp], eax
	call f300_locate_node_h
.return8:
	add esp, 8
	ret
.return:
	ret


;  f300_copy_node(buf, node)
f300_copy_node:
	push edi
	push esi
	push es
	
	mov ax, gs
	mov es, ax

	cld
	mov ecx, 0x10
	mov edi, [esp + 16]
	mov esi, [esp + 20]
	rep movsb
	
	pop es
	pop esi
	pop edi
	ret


; starts a search in a directory, returns the first node, 0 in none left
; f300_find_first(dir_to_search)
f300_find_first:
	mov eax, [esp + 4]
	mov eax, [eax + 8]
	test eax, eax
	jz .return
	push eax
	call f300_resolve_entry_ptr
	add esp, 4
.return:
	ret


; f300_find_next(last_file_found)
f300_find_next:
	mov eax, [esp + 4]
	mov eax, [eax + 12]
	test eax, eax
	jz .return
	push eax
	call f300_resolve_entry_ptr
	add esp, 4
.return:
	ret


; creates an empty node in the f300 file system table
;  f300_add_node(parent, flags, name)
f300_add_node:
	; TODO
	ret


; remove a node from the file system table
;  f300_remove_node(node)
f300_remove_node:
	; TODO
	ret


; appends a specified amount of blocks to a specified file
;  append_file(node, blocks)
append_file:
	; TODO
	ret


; adds an entry to the name string table
;  f300_add_nte(name*, name_size)
f300_add_nse:
	; TODO
	ret


; remove a name string entry
;  f300_remove_nte(name_ptr)
f300_remove_nse:
	; TODO
	ret
