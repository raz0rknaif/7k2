; Seven Kingdoms 2: The Fryhtan War
;
; Copyright 1999 Enlight Software Ltd.
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;

;Filename    : IB_BARM.ASM
;Description : Blt a bitmap to the display surface buffer without color key transparency handling
;		but with colour Remapping


INCLUDE imgfun.inc
INCLUDE colcode.inc
INCLUDE i_effect.inc

.CODE


;----------- BEGIN OF FUNCTION IMGbltBlendAreaRemapHMirror ------------
;
; Put an non-compressed bitmap on image buffer.
; It does not handle color key transparency.
; It can blt a specific area of the source image to the
; destination buffer instead of the whole source image.
; It handles colour remapping
;
; Syntax : IMGbltBlendAreaRemapHMirror( imageBuf, pitch, desX, desY, bitmapBuf, srcX1, srcY1, srcX2, srcY2, colorTable )
;
; char *imageBuf    - the pointer to the display surface buffer
; int  pitch     - pitch of the display surface buffer
; int  desX, desY   - where to put the area on the surface buffer
; char *bitmapPtr   - the pointer to the bitmap buffer
; int  srcX1, srcY1 - where to get the area on the source buffer
;      srcX2, srcY2
; short *colorTable  - a 256-entry color remapping table
;
;-------------------------------------------------
;
; Format of the bitmap data :
;
; <short>  width
; <short>  height
; <char..> bitmap image
;
;-------------------------------------------------

		PUBLIC    IMGbltBlendAreaRemapHMirror
IMGbltBlendAreaRemapHMirror	PROC   	  imageBuf, pitch, desX, desY, bitmapPtr, srcX1, srcY1, srcX2, srcY2, colorTable
		LOCAL	  srcLineDiff, drawWidth, lineDiff
		STARTPROC

		MOV	EAX, imageBuf		; store the address of the image buffer to a variable
		MOV	image_buf, EAX

		;------ get the bitmap width and height -----;

		MOV     AX , DS
		MOV	ES , AX
		MOV     ESI, bitmapPtr

		XOR	EAX, EAX
		LODSW                            ; get bitmap width
		MOV     EBX, EAX
		ADD	ESI, 2			 ; by pass the bitmap height, we don't need it. srcY2 and srcY1 will give us the data we need

		MUL     srcY1			 ; calculate the source starting address
		SUB	EAX, srcX2               ; bitmap width * srcY1 + bitmap width - srcX2 -1
		ADD	EAX, EBX
		DEC	EAX
		LEA	ESI, [ESI+2*EAX]

		MOV	EAX, srcX2		 ; srcLineDiff = bitmap width - (srcX2-srcX1+1)
		SUB	EAX, srcX1
		INC	EAX

		MOV	srcLineDiff, EBX
		SUB	srcLineDiff, EAX
		SHL	srcLineDiff, 1		 ; two bytes per pixel

		MOV	EDX, pitch	 ; EDX = lineDiff
		ADD	EDX, EAX		 ; lineDiff = pitch + 2*(srcX2-srcX1+1)
		ADD	EDX, EAX
		MOV	lineDiff, EDX

		MOV	drawWidth, EAX		 ;  line pixel copy count

		MOV	ECX, srcY2		 ; blt lines = srcY2-srcY1+1
		SUB	ECX, srcY1
		INC	ECX

		CLD                              ; clear direction flag for MOVSB

		;---------- pixels copying loop ----------;

		CALC_ADDR_2 EDI, desX, desY, srcX2, srcY1, pitch     ; Get the address to the destination buffer
		MOV	EBX, colorTable
		ADD	EDI, 2				; pre increase EDI

		ALIGN	4
@@putLine:
		PUSH	ECX
		MOV     ECX, drawWidth

		ALIGN	4
@@putPoint:
		PUSH	ECX
		MOVSX	EAX, WORD PTR [ESI]
		SUB	EDI, 2
		ADD	ESI, 2
		MOV	DX, [EDI]
		MOVSX	ECX, AH
		PRE_REMAP
		POST_REMAP
		SHR	DX, CL
		AND	DX, log_alpha_mask[ECX*2]
		ADD	AX, DX

		MOV	[EDI], AX
		POP	ECX
		LOOP	@@putPoint

		ADD	ESI, srcLineDiff
		ADD	EDI, lineDiff

		POP	ECX
		LOOP    @@putLine                ; decrease the remain height and loop

@@end:          ENDPROC
IMGbltBlendAreaRemapHMirror ENDP

;----------- END OF FUNCTION IMGbltBlendAreaRemapHMirror ----------


END
