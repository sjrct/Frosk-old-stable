;
; ata.asm
;
; written by sjrct
;


; this function detects ata bus devices
; cx bit 7 = prim/sec bus, cx bit 0 = master/slave
;
; TODO: when this is called twice, on the same bus and the first (master/slave)
;	exists, and then it is called on the other on the same bus, it will believe
;	it exists not matter what
; TODO: furthermore, i commented out the kalloc call because i no longer have 
;	such a function, so it will not read to any valid location. fix w/ location
;	passed into the function
;
; returns location of drive info if sucessful, 0 if not
ata_identify:
	push edi
	pushf

	; check for floating bus
	mov dx, cx
	not dx
	and dx, 0x80
	add dx, 0x177
	in al, dx
	cmp al, 0xff
	je .return_false

	; set to specified drive
	dec dx
	mov al, cl
	and al, 1
	shl al, 4
	or al, 0xa0
	out dx, al

	; zero ports 1[7,f]2-1[7,f]5
	mov cx, dx
	sub cx, 5
	dec dx
	xor al, al
.zero_loop:
	out dx, al
	dec dx
	cmp dx, cx
	jne .zero_loop
	
	; send indentify command
	add dx, 6
	mov al, 0xec
	out dx, al
	
	; check results
	in al, dx
	test al, al
	je .return_false
	mov cx, 0xffff
.wait_until_done:
	pause
	in al, dx
	and al, 0x80
	dec cx
	test cx, cx
	je .return_false
	test al, al
	jne .wait_until_done
	
	sub dx, 3
	in al, dx
	test al, al
	jne .return_false
	inc dx
	in al, dx
	test al, al
	jne .return_false
		
	add dx, 2
	mov cx, 0xffff
.wait_some_more:
	pause
	in al, dx
	and al, 0x09
	dec cx
	test cx, cx
	je .return_false
	test al, al
	je .wait_some_more
	
	and al, 1
	test al, al
	jne .return_false
	
	; good, read 512 bytes
	push dword 0x200
;	call kalloc
	add esp, 4
	mov edi, eax
	
	cld
	sub dx, 7
	mov ecx, 0x100
	rep insw
	
	; return from ata_identify function
	jmp .return
.return_false:
	xor eax, eax
.return:
	popf
	pop edi
	ret
	
	
; this function resets the drives on one of the selected buses
; target bus in high bit of cx, low bit ignored
;	NOT TESTED
ata_reset:
	not cx
	and cx, 0x80
	mov dx, cx
	add dx, 0x376
	mov al, 0x2
	out dx, al
	io_wait
	; idk what to do in between the writes to 376/3f6
	xor al, al
	out dx, al
	ret
	

; this function is for reading from the disk drive with ata pio mode (28-bit lba)
; returns the number of bytes read
; TODO: should be adjusted for relative lba addressing based on the partition
;		also, does not work after call to ata_identify, fix dis
;
;   ata_read_pio(dest, drive, lba, sector_count)
ata_read_pio:
	push ebp
	mov ebp, esp
	push edi
	push ebx
	pushf
		
	mov ecx, [ebp + 12]
	mov dx, cx
	not dx
	and dx, 0x80
	add dx, 0x176

	; set specified drive & lba on & bits 24-27 of lba address
	mov al, cl
	and al, 1
	shl al, 4
	or al, 0xe0
	mov ecx, [ebp + 16]
	shr ecx, 24
	and cl, 0xf
	or al, cl
	out dx, al
	
	; set sector count
	sub dx, 4
	mov eax, [ebp + 20]
	out dx, al
	
	; set bits 0-23 of lba address
	inc dx
	mov eax, [ebp + 16]
	out dx, al
	shr eax, 8
	inc dx
	out dx, al
	shr eax, 8
	inc dx
	out dx, al
	
	; send read command
	add dx, 2
	mov al, 0x20
	out dx, al
	
	; delay for 400ns for command to register
	mov ecx, 4
.delay400ns:
	in al, dx
	loop .delay400ns
	
	cld
		
	; poll status while drive is busy
.wait_until_done:
	pause
	in al, dx
	test al, 0x80
	jne .wait_until_done
	
	; check for error
	in al, dx
	test al, 1
	jne .return_err
	
	push es
	mov ax, gs
	mov es, ax

	; read data
	mov ebx, [ebp + 20]
	mov edi, [ebp + 8]
.read_loop:
	in al, dx
	test al, 8
	je .read_loop_break
	sub dx, 7
	mov ecx, 0x100
	rep insw
	add dx, 7
	dec ebx
	test ebx, ebx
	jne .read_loop
.read_loop_break:

	pop es

	; return
	mov ecx, [ebp + 8]
	mov eax, edi
	sub eax, ecx
	jmp .return
.return_err:
	sub dx, 6
	in al, dx
	or eax, 0xffffff00
.return:
	popf
	pop ebx
	pop edi
	pop ebp
	ret


; this function is for writing from the disk drive with ata pio mode (28-bit lba)
; returns the number of bytes writen
; TODO: should be adjusted for relative lba addressing based on the partition
;		also, does not work after call to ata_identify, fix dis
;
;   ata_write_pio(source, drive, lba, sector_count)
ata_write_pio:
	push ebp
	mov ebp, esp
	push esi
	push ebx
	pushf

	mov ecx, [ebp + 12]
	mov dx, cx
	not dx
	and dx, 0x80
	add dx, 0x176

	; set specified drive & lba on & bits 24-27 of lba address
	mov al, cl
	and al, 1
	shl al, 4
	or al, 0xe0
	mov ecx, [ebp + 16]
	shr ecx, 24
	and cl, 0xf
	or al, cl
	out dx, al
	
	; set sector count
	sub dx, 4
	mov eax, [ebp + 20]
	out dx, al
	
	; set bits 0-23 of lba address
	inc dx
	mov eax, [ebp + 16]
	out dx, al
	shr eax, 8
	inc dx
	out dx, al
	shr eax, 8
	inc dx
	out dx, al
	
	; send write command
	add dx, 2
	mov al, 0x30
	out dx, al
	
	; delay for 400ns for command to register
	mov ecx, 4
.delay400ns:
	in al, dx
	loop .delay400ns
	
	cld
		
	; poll status while drive is busy
.wait_until_done:
	pause
	in al, dx
	test al, 0x80
	jne .wait_until_done
	
	; check for error
	in al, dx
	test al, 1
	jne .return_err
	
	push ds
	mov ax, gs
	mov ds, ax

	; write data
	mov ebx, [ebp + 20]
	mov esi, [ebp + 8]
.read_loop:
	in al, dx
	test al, 8
	je .read_loop_break
	sub dx, 7
	mov ecx, 0x100
	rep outsw
	add dx, 7
	dec ebx
	test ebx, ebx
	jne .read_loop
.read_loop_break:

	pop ds

	; return
	mov ecx, [ebp + 8]
	mov eax, esi
	sub eax, ecx
	jmp .return
.return_err:
	sub dx, 6
	in al, dx
	or eax, 0xffffff00
.return:
	popf
	pop ebx
	pop esi
	pop ebp
	ret
