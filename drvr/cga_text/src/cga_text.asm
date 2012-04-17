;
; cga_text.asm
;
; written by sjrct
;

[bits 32]

%include "src/def.asm"

; the drvr file header
header:
	db 'drvr'
	dd call_drvr
	dd code_end - call_drvr
	dd data_start
	dd data_end - data_start
	dd 0x10


; function called on drvr call
; TODO optimize
; eax = function id
call_drvr:
	push ebx
	push es
	mov ebx, esp

	mov cx, 0x10	; kern_ds
	mov es, cx

	cmp eax, FUNC_COUNT
	ja .return

	mov ecx, [(func_tbl - data_start) + eax * 8 + 4]
	
.push_loop:
	jecxz .push_loop_break
	push dword [ebp + 12 + ecx * 4]
	dec ecx
	jmp .push_loop
.push_loop_break:

	call [(func_tbl - data_start) + eax * 8]
.return:

	mov esp, ebx
	pop es
	pop ebx
	retf


; asdf
init:
	ret


; this function clears the screen w/ size of 80x25
cls:
	cld
	mov al, 0x20
	mov ah, [ink - data_start] 
	mov edi, 0xb8000
	mov ecx, 80 * 26
	rep stosw
	
	mov dword [buffer_loc - data_start], 0xb8000

	call update_cursor

	ret
	

; This function writes a string to the screen
puts:
	push ebx
	mov ebx, [esp + 8]	

.loop:
	mov al, [gs:ebx]
	test al, al
	jz .break
	push eax
	call putc
	add esp, 4
	inc ebx
	jmp .loop
.break:
	
	pop ebx
	ret


; this function writes a hex dword to the screen
puth:
	mov ecx, [esp + 4]
	mov edx, [buffer_loc - data_start]
	add edx, 0xe
	mov ah, [ink - data_start]

.loop:
	mov al, cl
	and al, 0xf
	
	cmp al, 0xa
	jae .add_let
	
	add al, "0"
	jmp .out
.add_let:
	add al, 0x37
.out:

	mov [es:edx], al
	mov byte [es:edx + 1], ah
	sub edx, 2
	
	shr ecx, 4
	test ecx, ecx
	jnz .loop

	mov edx, [buffer_loc - data_start]
	add edx, 0x10
	mov [buffer_loc - data_start], edx

	call scroll_check
	call update_cursor
	ret
	
	
; this function outputs a character to the screen
;   kputc(dword char)
putc:
	mov eax, [esp + 4]
	
	cmp al, 0xa
	jne .not_newline
	
	call newline
	ret
.not_newline:

	cmp al, 0x8
	jne .not_backspace
	
	mov ecx, [buffer_loc - data_start]
	sub ecx, 2
	mov byte [es:ecx], 0
	mov [buffer_loc - data_start], ecx
	call update_cursor
	ret
.not_backspace:
	
	mov ecx, [buffer_loc - data_start]
	mov [es:ecx], al
	mov ah, [ink - data_start]
	mov byte [es:ecx + 1], ah
	
	add ecx, 2
	mov [buffer_loc - data_start], ecx

	call scroll_check
	call update_cursor
	ret
	
	
; this function handles newline output to the video memory
newline:
	push ebx
	
	mov ecx, [buffer_loc - data_start]
	mov eax, ecx
	sub eax, 0xb8000
	xor edx, edx
	mov ebx, 0xa0
	div ebx
	
	sub ecx, edx
	add ecx, 0xa0
	mov [buffer_loc - data_start], ecx
	
	call scroll_check
	call update_cursor
	
	pop ebx
	ret
	
	
; function checks if the screen should scroll from excess input
; written for 80x25 res
scroll_check:
	mov eax, [buffer_loc - data_start]
	cmp eax, 0xb8000 + 80 * 25 * 2
	jb .no_scroll

	push eax	
	mov eax, 0xb8000 + 80 * 26 * 2
	mov ecx, -0x80 * 24 * 2
.loop:
	mov dl, [es:eax + ecx]
	mov [es:eax + ecx - 80 * 2], dl
	inc ecx
	test ecx, ecx
	jnz .loop
	pop eax
	
	sub eax, 80 * 2
	mov [buffer_loc - data_start], eax
	
	call scroll_check	
	
.no_scroll:
	ret


;
setink:
	mov eax, [esp + 4]
	mov [ink - data_start], al
	ret


;
getink:
	mov eax, [ink - data_start]
	ret


;
puti:
	; TODO
	ret


; outputs a character to a specific location on the screen
; the cursor remains unchanged
;  outc(x, y, char)
outc:
	mov eax, [esp + 8]
	imul eax, 80 * 2
	mov ecx, [esp + 4]
	shl ecx, 1
	add eax, ecx
	add eax, 0xb8000

	mov ecx, [esp + 12]
	mov edx, [ink - data_start]
	mov ch, dl

	push ds
	mov dx, 0x10 ;	kern ds
	mov ds, dx
	mov [eax], cx
	pop ds
	ret


; updates the cursor based on the buffer_loc value
update_cursor:
	mov ecx, [buffer_loc - data_start]
	sub ecx, 0xb8000
	shr ecx, 1

	mov dx, 0x3d4
	mov al, 0xf
	out dx, al
	inc dx
	mov al, cl
	out dx, al

	dec dx
	mov al, 0xe
	out dx, al
	inc dx
	mov al, ch
	out dx, al
	ret


; the size is specied in scanlines
setcursorsize:
	mov dx, 0x3d4
	mov al, 0xa
	out dx, al
	inc dx
	mov eax, [esp + 4]
	and al, 0x1f
	out dx, al

	dec dx
	mov al, 0xb
	out dx, al
	inc dx
	mov eax, [esp + 8]
	and al, 0x1f
	out dx, al
	ret


; sets the blink rate for characters
setblinkrate:
	mov dx, 0x3d4
	mov al, 0xdd
	out dx, al
	inc dx
	in al, dx
	and al, 0xf
	mov ecx, [esp + 4]
	and cl, 0xf0
	or al, cl
	out dx, al
	ret


; shows cursor while preserving cursor start scanline
showcursor:
	mov dx, 0x3d4
	mov al, 0xa
	out dx, al
	inc dx
	in al, dx
	and al, 0x1f
	out dx, al
	ret
	

; hides cursor while preserving cursor start scanline
hidecursor:
	mov dx, 0x3d4
	mov al, 0xa
	out dx, al
	inc dx
	in al, dx
	and al, 0x1f
	or al, 0x20
	out dx, al
	ret


;  setcursor(x,y)
setcursor:
	mov ecx, [esp + 8]
	imul ecx, 80
	add ecx, [esp + 4]
	mov eax, ecx
	shl eax, 1
	add eax, 0xb8000
	mov [buffer_loc - data_start], eax

	mov dx, 0x3d4
	mov al, 0xf
	out dx, al
	inc dx
	mov al, cl
	out dx, al

	dec dx
	mov al, 0xe
	out dx, al
	inc dx
	mov al, ch
	out dx, al
	ret


;
getcursorx:
	; TODO
	ret


;
getcursory:
	; TODO
	ret


code_end:

%include "src/data.asm"
