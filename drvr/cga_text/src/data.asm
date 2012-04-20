;
; data.asm
;
; written by sjrct
;

data_start:

align 4

func_tbl:
	dd init - call_drvr
	dd 0
	dd putc - call_drvr
	dd 1
	dd puts - call_drvr
	dd 1
	dd puth - call_drvr
	dd 1
	dd puti - call_drvr
	dd 1
	dd setink - call_drvr ; 5
	dd 1
	dd getink - call_drvr
	dd 0
	dd cls - call_drvr
	dd 0
	dd outc - call_drvr
	dd 3
	dd showcursor - call_drvr
	dd 0
	dd hidecursor - call_drvr	; 10
	dd 0
	dd setcursor - call_drvr
	dd 2
	dd getcursorx - call_drvr
	dd 0
	dd getcursory - call_drvr
	dd 0
	dd setcursorsize - call_drvr
	dd 2
	dd setblinkrate - call_drvr	; 15
	dd 1

buffer_loc: dd 0xb8000
ink: db 0x0f
	
data_end:
