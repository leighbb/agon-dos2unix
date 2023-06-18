;
; Title:		AGON MOS - MOS assembly interface
; Author:		Jeroen Venema
; Updated by:		Leigh Brown
; Created:		15/10/2022
; Last Updated:		18/06/2023
; 
; Modinfo:
; 15/10/2022:		Added _putch, _getch
; 21/10/2022:		Added _puts
; 22/10/2022:		Added _waitvblank, _mos_f* file functions
; 26/11/2022:       __putch, changed default routine entries to use IY
; 10/01/2023:		Added _getsysvar_cursorX/Y and _getsysvar_scrchar
; 23/02/2023:		Added _mos_save and _mos_del, also changed stackframe to use ix exclusively
; 18/06/2023:		Added some additional functions

	.include "mos_api.inc"

	XDEF _exit
	XDEF _putch
	XDEF _getch
	XDEF _waitvblank
	XDEF _mos_fopen
	XDEF _mos_fclose
	XDEF _mos_fgetc
	XDEF _mos_fputc
	XDEF _mos_feof
	XDEF _mos_fread
	XDEF _mos_fwrite
	XDEF _mos_puts
	XDEF _mos_write
	XDEF _mos_save
	XDEF _mos_del
	XDEF _mos_oscli
	XDEF _mos_sysvars
	XDEF _getsysvar_cursorX
	XDEF _getsysvar_cursorY
	XDEF _getsysvar_scrchar
	
	segment CODE
	.assume ADL=1
	
_exit:
	jr _exit

_putch:
	push ix
	ld ix,0
	add ix,sp
	ld a, (ix+6)
	rst.lil 10h
	pop ix
	ret

_getch:
	push	ix
	ld	a, mos_sysvars
	rst.lil	08h
_getch0:
	; Wait for a key packet to arrive
	ld	a,(ix+sysvar_keyascii)
	or	a,a
	jr	z,_getch0

	; Reset keyascii
	ld	(ix+sysvar_keyascii),0

	; Check if it's a key down event, if not, keep waiting
	ld	b,a
	ld	a,(ix+sysvar_keydown)
	or	a
	jr	z,_getch0

	; Return the ASCII code
	ld	a,b
	pop	ix
	ret

_waitvblank:
	push ix
	ld a, mos_sysvars
	rst.lil 08h
	ld a, (ix + sysvar_time + 0)
$$:	cp a, (ix + sysvar_time + 0)
	jr z, $B
	pop ix
	ret

_mos_sysvars:
	push	ix
	ld	a,mos_sysvars
	rst.lil	08h
	lea	hl,ix+0
	pop	ix
	ret

_getsysvar_cursorX:
	push ix
	ld a, mos_sysvars			; MOS Call for mos_sysvars
	rst.lil 08h					; returns pointer to sysvars in ixu
	ld a, (ix+sysvar_cursorX)	; get current keycode
	pop ix
	ret

_getsysvar_cursorY:
	push ix
	ld a, mos_sysvars			; MOS Call for mos_sysvars
	rst.lil 08h					; returns pointer to sysvars in ixu
	ld a, (ix+sysvar_cursorY)	; get current keycode
	pop ix
	ret

_getsysvar_scrchar:
	push ix
	ld a, mos_sysvars			; MOS Call for mos_sysvars
	rst.lil 08h					; returns pointer to sysvars in ixu
	ld a, (ix+sysvar_scrchar)	; get current keycode
	pop ix
	ret

_getsysvar_scrcols:
	push ix
	ld a, mos_sysvars
	rst.lil 08h
	ld a, (ix+sysvar_scrcols)
	pop ix
	ret

_getsysvar_scrrows:
	push ix
	ld a, mos_sysvars
	rst.lil 08h
	ld a, (ix+sysvar_scrrows)
	pop ix
	ret

_mos_fopen:
	push ix
	ld ix,0
	add ix, sp
	
	ld hl, (ix+6)	; address to 0-terminated filename in memory
	ld c,  (ix+9)	; mode : fa_read / fa_write etc
	ld a, mos_fopen
	rst.lil 08h		; returns filehandle in A
	
	ld sp,ix
	pop ix
	ret	

_mos_fclose:
	push ix
	ld ix,0
	add ix, sp
	
	ld c, (ix+6)	; filehandle, or 0 to close all files
	ld a, mos_fclose
	rst.lil 08h		; returns number of files still open in A
	
	ld sp,ix
	pop ix
	ret	

_mos_fgetc:
	push ix
	ld ix,0
	add ix, sp
	
	ld c, (ix+6)	; filehandle
	ld a, mos_fgetc
	rst.lil 08h		; returns character in A
	ld	hl,0
	ld	l,a
	jr	nc,$f
	ld	h,1
$$:	ld sp,ix
	pop ix
	ret	

_mos_fputc:
	push ix
	ld ix,0
	add ix, sp
	
	ld c, (ix+6)	; filehandle
	ld b, (ix+9)	; character to write
	ld a, mos_fputc
	rst.lil 08h		; returns nothing
	
	ld sp,ix
	pop ix
	ret	

_mos_feof:
	push ix
	ld ix,0
	add ix, sp
	
	ld c, (ix+6)	; filehandle
	ld a, mos_feof
	rst.lil 08h		; returns A: 1 at End-of-File, 0 otherwise
	
	ld sp,ix
	pop ix
	ret	

_mos_fread:
	push ix
	ld ix,0
	add ix,sp

	ld c, (ix+6)	; UINT8 filehandle
	ld hl, (ix+9)	; UINT24 buffer
	ld de, (ix+12)	; UINT24 bytes to read

	ld a, mos_fread
	rst.lil 08h

	; Move 24-bit result from DE into HL
	push	de
	pop	hl

	; Return
	ld sp,ix
	pop ix
	ret

_mos_fwrite:
	push ix
	ld ix,0
	add ix,sp

	ld c, (ix+6)	; UINT8 filehandle
	ld hl, (ix+9)	; UINT24 buffer
	ld de, (ix+12)	; UINT24 bytes to write

	ld a, mos_fwrite
	rst.lil 08h

	; Move 24-bit result from DE into HL
	push	de
	pop	hl

	; Return
	ld sp,ix
	pop ix
	ret

_mos_write:
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+6)
	ld	bc,(ix+9)
	rst.lil	18h
	pop	ix
	ret

_mos_puts:
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+6)
	ld	bc,0
	ld	a,0
	rst.lil	18h
	pop	ix
	ret

_mos_del:
	push	ix
	ld 		ix,0
	add 	ix, sp

	ld 		hl, (ix+6)	; filename address (zero terminated)
	ld a,	mos_del
	rst.lil	08h			; save file to SD card

	ld		sp,ix
	pop		ix
	ret
	
_mos_save:
	push	ix
	ld 	ix,0
	add 	ix, sp

	ld 	hl, (ix+6)	; filename address (zero terminated)
	ld	de, (ix+9)	; address to save from
	ld	bc, (ix+12)	; number of bytes to save
	ld	a, mos_save
	rst.lil	08h			; save file to SD card

	ld	sp,ix
	pop	ix
	ret

_mos_oscli:
	push	ix
	ld	ix,0
	add	ix,sp

	ld	hl,(ix+6)
	ld	a, mos_oscli
	rst.lil	08h

	ld	sp,ix
	pop	ix
	ret
	
	SEGMENT DATA

END

