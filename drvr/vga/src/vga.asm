;
; vga.asm
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
	dd 0x11


; on call to the driver (eax = func id)
call_drvr:
	cmp eax, FUNC_COUNT
	jae .return
	call [(func_tbl - data_start) + eax * 4]
.return:
	retf


; does some stuff
init:
	mov dx, 0x3cc
	in al, dx
	mov cl, al
	and al, 0xc0
	mov dx, 0x3c2
	out dx, al
	ret

code_end:

%include "src/data.asm"
