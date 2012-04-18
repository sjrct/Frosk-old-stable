;
; boot.asm
;
; written by sjrct
;

%include "kernel/def.asm"

[bits 16]
[org BOOT_ORG]


;-----------------------;
; code section (16-bit) ;
;-----------------------;

start:
	; setup segment registers and stack
	sub ax, ax
	mov ss, ax
	mov ds, ax
	mov es, ax

	mov sp, BOOT_ORG	; put stack below bootloader for now
	mov bp, sp

	; check if can use extenions to bios int 0x13
	mov ah, 0x41
	mov bx, 0x55aa		;~~~MAGIC!~~~
	int 0x13
	jc error16 ; 0
	inc byte [error_msg_num]

	push dx
	
	; map the physical memory on the system
	mov di, MEM_MAP_LOC + 8
	mov edx, 0x534d4150	;~~~MAGUS!~~~
	xor ebx, ebx
mem_map_loop:
	mov eax, 0xe820
	mov ecx, 24
	int 0x15
	jc .break
	test ebx, ebx
	jz .break
	
	mov eax, [di + 8]
	test eax, eax
	jne .not_empty
	mov eax, [di + 12]
	test eax, eax
	je mem_map_loop
.not_empty:
	
	add di, 24
	jmp mem_map_loop
.break:
	cmp di, MEM_MAP_LOC + 8
	je error16 ; 1
	inc byte [error_msg_num]
	mov [MEM_MAP_LOC], di
	
	mov bx, sp
	mov dx, [bx]

	; read the fs from the drive
	mov cx, 5
read1_again:
	mov ah, 0x42
	mov si, dap
	int 0x13
	jnc read1_good

	dec cx
	test cx, cx
	jnz read1_again
	jmp error16 ; 2
read1_good:

	inc byte [error_msg_num]

	; check that it is a f300 fs
	cmp word [FST_LOC], 0xf300
	jne error16 ; 3
	inc byte [error_msg_num]
		
	; find the kernel file
	; the kernel should be in the prebranch and the first metablock
	mov bx, [FST_LOC + 0x10]
	and bx, 0xff
	shl bx, 4
	add bx, FST_LOC + 8
	mov bx, [bx]
search_for_kern_loop:
	and bx, 0xff
	shl bx, 4
	add bx, FST_LOC + 4

	mov si, [bx]
	and si, 0xff
	shl si, 4
	add si, FST_LOC + 2
	mov di, kern_fn

.name_check_loop:
	mov al, [si]
	mov ah, [di]

	cmp al, ah	
	jne .next
	test al, al
	jz .break
	inc si
	inc di
	jmp .name_check_loop

.next:
	mov bx, [bx + 8]
	test bx, bx
	jz error16 ; 4
	jmp search_for_kern_loop
.break:

	inc byte [error_msg_num]

	; get block structure location
	mov bx, [bx + 4]
	and bx, 0xff
	shl bx, 4
	add bx, FST_LOC

	pop dx
	
	; read the kernel file
	; Note: does not support kernel files w/ more than 2^16 sectors
	mov eax, [bx]
	shr eax, 8
	shl ax, 3
	mov [dap + 2], ax
	mov eax, [bx + 8]
	rol eax, 3
	mov ecx, eax
	and ecx, 7
	and eax, ~7
	mov [dap + 8], eax
	mov eax, [bx + 12]
	shl eax, 3
	or eax, ecx
	mov [dap + 12], eax
	mov dword [dap + 4], KERN_ORG

	mov cx, 5
read2_again:
	mov ah, 0x42
	mov si, dap
	int 0x13
	jnc read2_good

	dec cx
	test cx, cx
	jne read2_again
	jmp error16 ; 5
read2_good:

	; Load the temporary GDT
	cli
	lgdt [gdt_ptr]
	
	; Switch cr0 to 32-bit mode
	mov eax, cr0
	or al, 1
	mov cr0, eax

	; flush the instruction prefetch queue
	jmp Code_Seg_Sel:pm32
	
; 16 bit error function
error16:
	cld
	mov ax, 0xb800
	mov es, ax
	mov cx, [error_msg_size]
	mov si, error_msg
	sub di, di
	rep movsb
	jmp $
	

;-----------------------;
; Code section (32-bit) ;
;-----------------------;

[bits 32]

pm32:
	; Setup stack/segment registers for 32-bit mode
	mov ax, KERN_DS
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov eax, KERN_STACK
	mov esp, eax
	mov ebp, esp
	
	; jump to the kernel
	jmp KERN_ORG


;--------------;
; Data section ;
;--------------;

; error message string
error_msg:
	db 'E', 4, 'r', 4, 'r', 4, 'o', 4, 'r', 4, ' ', 4
error_msg_num:
	db '0', 4
	db ' ', 4
error_msg_size:
	dw 14

; kernel file name string
kern_fn:
	db "krn.bin", 0
kern_fn_size:
	dw 8
	
; the address packet for reading the fs header
dap:
	db 0x10
	db 0
	dw 8
	dd FST_LOC
	dq 8
	
; The temporary global descriptor table
gdt_ptr:
	dw gdt.end - gdt    ; the size of the gdt
	dd gdt              ; Tbe location of the gdt
gdt:
.null_seg:
	dw 0x0000           ; low-word of length
	dw 0x0              ; low-word of base address
	db 0x0              ; mid-byte of base address
	db 0x00             ; flags
	db 0x0              ; access/length
	db 0x0              ; high byte of base address
.code_seg:
	dw 0xffff
	dw 0x0
	db 0x0
	db 0x9a
	db 0xcf
	db 0x0
.data_seg:
	dw 0xffff
	dw 0x0
	db 0x0
	db 0x92
	db 0xcf
	db 0x0
.end:

Code_Seg_Sel: equ gdt.code_seg - gdt
Data_Seg_Sel: equ gdt.data_seg - gdt

; Mark as bootable & fill remainder of first block
times 0x1fe - ($ - $$) db 0
dw 0xaa55
times 0x1000 - ($ - $$) db 0
