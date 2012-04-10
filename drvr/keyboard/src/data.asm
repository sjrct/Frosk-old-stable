;
; data.asm
;
; written by sjrct
;

data_start:

func_tbl:
	dd init - call_drvr
	dd getsc - call_drvr
	dd trygetsc - call_drvr
	dd getbufsize - call_drvr
	dd flushbuf - call_drvr

buffer_size: dd 0
led_states: dd 0

buffer:
	times BUF_MAX_SIZE db 0
data_end:; equ $ + BUF_MAX_SIZE
