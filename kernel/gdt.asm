;
; gdt.asm
;
; written by sjrct
;

; copies over the gdt from boot, and sets first_free_gdte
setup_gdt:
	; copy over the old GDT from the bootloader
	sgdt [gdt_ptr]
	mov esi, [gdt_ptr + 2]
	mov edi, GDT_LOC
	mov [gdt_ptr + 2], edi
	xor ecx, ecx
	mov cx, [gdt_ptr]
	mov edx, ecx
	shr ecx, 2
	cld
	rep movsd
	
	xor eax, eax
	mov ecx, 0x800
	sub cx, [gdt_ptr]
	rep stosb
	
	add edx, GDT_LOC
	mov dword [first_free_gdte], edx
	
	mov word [gdt_ptr], 0x800
	lgdt [gdt_ptr]
	ret


; adds an entry to the gdt, returns the selector for the segment
;  add_gdt_entry(base, size, [access][flags][4 unused bits])
;
; TODO bug w/ loop around + handling of no remaining segments
add_gdt_entry:
	; find free gdt entry
	mov eax, [first_free_gdte]	
	mov edx, eax
.search_gdt_loop:
	cmp dword [eax], 0
	jne .search_gdt_loop_next
	cmp dword [eax + 4], 0
	je .found
.search_gdt_loop_next:
	add eax, 8
	cmp eax, edx
	je .nothing_left
	cmp eax, GDT_LOC + 0x800
	jne .search_gdt_loop
	mov eax, GDT_LOC + 8	
	jmp .search_gdt_loop
.nothing_left:
	; TODO
	push 0x5ade
	call kputh
	jmp $
.found:

	; make sure still free
	mov ecx, 1
	xchg [eax], ecx
	test ecx, ecx
	jnz .search_gdt_loop_next

	; setup gdt entry
	mov ecx, [esp + 4]
	mov [eax + 2], cx
	shr ecx, 16
	mov [eax + 4], cl
	mov [eax + 7], ch
	
	mov ecx, [esp + 8]
	mov [eax], cx
	shr ecx, 16
	mov edx, [esp + 12]
	or cl, dl
	mov [eax + 5], dh
	mov [eax + 6], cl

	; store eax + 8
	mov [first_free_gdte], eax

;	cli	
	lgdt [gdt_ptr]
;	sti

	sub eax, GDT_LOC
	ret


; frees a gdt entry, the table does not change in size
;  remove_gdt_entry(selector)
remove_gdt_entry:
	mov eax, [esp + 4]
	add eax, GDT_LOC
	xor ecx, ecx
	mov [eax], ecx
	mov [eax + 4], ecx
	ret
