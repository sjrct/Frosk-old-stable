;
; keyboard.asm
;
; written by sjrct
;

[bits 32]

%include "src/def.asm"

; header for drvr file format
header:
	db 'drvr'
	dd call_drvr
	dd code_end - call_drvr
	dd data_start
	dd data_end - data_start
	dd DRVR_ID


; called on int 0x41, ecx = 1
; eax = func id
call_drvr:
	cmp eax, FUNC_COUNT
	jae .return
	call [(func_tbl - data_start) + eax * 4]
.return:
	retf
	

; needs to be called before the driver is used
init:
	; add the keypress interrupt handler to the idt
	push 0x8f
	push cs
	push key_int - call_drvr
	push 0x21

	mov ecx, esp
	push ss
	push ecx
	xor eax, eax
	int 0x42
	
	add esp, 24

	; make sure leds are disabled
	mov al, 0xed
	out 0x64, al
	xor al, al
	out 0x60, al
	ret


; handles the key board IRQ (int 0x21)
key_int:
	push eax
	push ecx
	push edx
	
	push ds
	push es
	
	push DRVR_ID
	mov ecx, esp
	push ss
	push ecx
	mov eax, 4	; drvr_exists
	int 0x40
	add esp, 12

	mov cx, 0x10	; Kernel DS
	mov es, cx
	mov ax, [es:eax + 6]
	mov ds, ax

	xor eax, eax
	in al, 0x60
	mov edx, 2
	cmp al, 0x3a	; caps lock
	je .switch_led_state
	dec edx
	cmp al, 0x45	; num lock
	je .switch_led_state
	dec edx
	cmp al, 0x46	; scroll lock
	je .switch_led_state
.after_leds:

	mov ecx, [buffer_size - data_start]
	cmp ecx, BUF_MAX_SIZE
	jae .overflow

	mov [(buffer - data_start) + ecx], al
	inc ecx
	mov [buffer_size - data_start], ecx

.overflow:
	mov al, 0x20
	out 0x20, al
	
	pop es
	pop ds

	pop edx
	pop ecx
	pop eax
	iret
.switch_led_state:
	push eax
	mov al, 0xed
	out 0x64, al
	mov al, [led_states]
	btc eax, ebx
	mov [led_states], al
	out 0x60, al
	in al, 0x60
	pop eax
	jmp .after_leds
	

; get a scancode from a buffer, block if no scancode
getsc:
	mov ecx, [buffer_size - data_start]
	test ecx, ecx
	jnz .wait_loop_break
.wait_loop:
	pause
	mov ecx, [buffer_size - data_start]
	jecxz .wait_loop
.wait_loop_break:

	xor eax, eax
	dec ecx
	mov al, [(buffer - data_start) + ecx]
	mov [buffer_size - data_start], ecx
	ret


; get a character from a buffer, no blocking
trygetsc:
	mov ecx, [buffer_size - data_start]
	test ecx, ecx
	jnz .not_empty
	mov eax, -1
	jmp .return	
.not_empty:
	xor eax, eax
	dec ecx
	mov ax, [(buffer - data_start) + ecx]
	mov [buffer_size - data_start], ecx
.return:
	ret


; returns the bytes (scancodes*2) in the buffer
getbufsize:
	mov eax, [buffer_size - data_start]
	shr eax, 1
	ret


;
flushbuf:
	; TODO
	ret


; tells the keyboard to send scancodes
enable_scancodes:
	mov al, 0xf4
	out 0x64, al
	ret


; tells the keyboard not to send scancodes
disable_keyboard:
	mov al, 0xf5
	out 0x64, al
	ret


code_end:

%include "src/data.asm"
