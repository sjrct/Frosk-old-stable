;
; kio.asm
;
; written by sjrct
;
; handles very basic I/O in kernel space
;


%define INP_BUF_MAX		1024

;--------------;
; Code section ;
;--------------;

; this function clears the screen; note that the screen is the text buffer in
; b8000 hex
kcls:
	pushf

	cld
	xor ax, ax
	mov edi, 0xb8000
	mov ecx, 80 * 25 * 2
	rep stosb
	
	mov dword [buffer_loc], 0xb8000
	
	; removes cursor
	mov dx, 0x3d4
	mov ax, 0xa
	out dx, ax
	inc dx
	mov ax, 0x10
	out dx, ax
	
	popf
	ret
	

; This function writes a string to the screen
;	note that the give location should be in the gs register
kputs:
	push ebp
	mov ebp, esp
	push ebx
	
	mov eax, [ebp + 8]

	mov ecx, [buffer_loc]
	sub edx, edx
	
.loop:
	mov bh, [gs:eax + edx]
	test bh, bh
	je .break
	
	mov [ecx + edx * 2], bh
	mov byte [ecx + edx * 2 + 1], 0x07
	
.next:
	inc edx
	jmp .loop
.break:
	
	shl edx, 1
	add ecx, edx
	mov [buffer_loc], ecx

	call scroll_check
 
	pop ebx
	pop ebp
	ret


; this function writes a hex dword to the screen
kputh:
	push ebp
	mov ebp, esp
	
	mov ecx, [ebp + 8]
	mov edx, [buffer_loc]
	add edx, 0xe
	
.loop:
	mov ax, cx
	and al, 0xf
	
	cmp al, 0xa
	jae .add_let
	
	add al, "0"
	jmp .out
.add_let:
	add al, 0x37
.out:

	mov [edx], al
	mov byte [edx + 1], 0x07
	sub edx, 2
	
	shr ecx, 4
	cmp ecx, 0
	jne .loop

	mov edx, [buffer_loc]
	add edx, 0x10
	mov [buffer_loc], edx

	call scroll_check
	
	pop ebp
	ret
	
	
; this function outputs a character to the screen
;   kputc(dword char)	//only first byte is used
kputc:
	mov eax, [esp + 4]
	
	cmp al, 0xa
	jne .not_newline
	
	call knewline
	ret
.not_newline:

	cmp al, 0x8
	jne .not_backspace
	
	mov ecx, [buffer_loc]
	sub ecx, 2
	mov byte [ecx + 1], 0x0
	mov [buffer_loc], ecx
	ret
.not_backspace:
	
	mov ecx, [buffer_loc]
	mov [ecx], al
	mov byte [ecx + 1], 0x07
	
	add ecx, 2
	mov [buffer_loc], ecx

	call scroll_check
	
	ret
	
	
; this function handles newline output to the video memory
knewline:
	push ebx
	
	mov ecx, [buffer_loc]
	mov eax, ecx
	sub eax, 0xb8000
	xor edx, edx
	mov ebx, 0xa0
	div ebx
	
	sub ecx, edx
	add ecx, 0xa0
	mov [buffer_loc], ecx
	
	call scroll_check
	
	pop ebx
	ret
	
	
; function checks if the screen should scroll from excess input
; written for 80x25 res
scroll_check:
	mov eax, [buffer_loc]
	cmp eax, 0xb8000 + 80 * 25 * 2
	jb .no_scroll
	push esi
	push edi

	mov ecx, 80 * 26 * 2
	mov edi, 0xb8000
	mov esi, 0xb8000 + 80 * 2
	rep movsb
	sub eax, 80 * 2
	mov [buffer_loc], eax

	pop edi
	pop esi
.no_scroll:
	ret
	
;--------------;
; Data Section ;
;--------------;

; the location to write next in the buffer
buffer_loc:
	dd 0xb8000


