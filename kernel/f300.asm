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
	mov eax, [gs:8] ; current directory
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


; allocates an 16 bytes entry in the file system table
;  f300_alloc_entry()
f300_alloc_entry:
	push ebx
	push esi
	xor esi, esi
	mov ebx, [first_fs_blocks]
	mov eax, 0x1010
.block_loop:
	mov edx, ebx
	and edx, 0xc
	cmp edx, 0xc
	jne .blocks_good
	; TODO
.blocks_good:
	mov edx, [ebx]
	test edx, edx
	jnz .block_good
	; TODO
.block_good:
	sub eax, 0xff0
.entry_loop:
	test byte [edx + eax], 1
	jz .found
	test byte [edx + eax], 2
	jz .not_string
	xor ecx, ecx
	mov cl, [edx + eax + 1]
	dec ecx
	shl ecx, 4
	add eax, ecx
.not_string:
	add eax, 0x10
	cmp eax, 0x1000	; page size
	jne .entry_loop
	add ebx, 4
	inc esi
	jmp .block_loop
.found:
	shr eax, 4
	or eax, esi
	pop esi
	pop ebx
	ret


; creates an empty node in the f300 file system table
;  f300_add_node(parent, flags, name)
f300_add_node:
	push esi
	call f300_alloc_entry
	mov esi, eax
	mov eax, [esp + 8]

	mov ecx, [eax + 8]
	test ecx, ecx
	jz .first_file
	push ecx
	call f300_resolve_entry_ptr
	add esp, 4
.search_loop:
	mov ecx, [eax + 12]
	test ecx, ecx
	jz .found
	push ecx
	call f300_resolve_entry_ptr
	add esp, 4
	jmp .search_loop
.found:
	mov [eax + 12], esi
.after_found:

	push esi
	call f300_resolve_entry_ptr
	add esp, 4
	
	mov edx, [esp + 12]
	or edx, 1
	mov [eax], dx
	mov dword [eax + 8], 0
	mov dword [eax + 12], 0

	; name
	; TODO fix for names above 14 bytes
	mov esi, eax
	call f300_alloc_entry
	mov [esi + 4], eax
	push eax
	call f300_resolve_entry_ptr
	add esp, 4
	mov byte [eax], 3
	mov byte [eax + 1], 1
	mov ecx, [esp + 16]
	add eax, 2
.str_copy:
	mov dl, [gs:ecx]
	mov [eax], dl
	inc ecx
	inc eax
	test dl, dl
	jnz .str_copy
	
	mov eax, esi

	pop esi
	ret
.first_file:
	mov [eax + 8], esi
	jmp .after_found


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
