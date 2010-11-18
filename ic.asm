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

;Filename    : IC.ASM
;Description : copy a rectange from one surface to another


INCLUDE IMGFUN.INC

.CODE

;--------- BEGIN OF FUNCTION IMGcopyW -----------
;
; Draw a bar on the VGA screen
;
; Note : No border checking is made in this function.
;	 Placing an icon outside image buffer will cause serious BUG.
;
; char *imageBuf   - the pointer to the display surface buffer
; int  imgPitch    - pitch of the display surface buffer
; char *backBuf    - the pointer to the source surface buffer
; int  backPitch   - pitch of the source display surface buffer
; int  x1,y1       - the top left vertex of the bar ( note : width < 1024)
; int  x2,y2       - the bottom right vertex of the bar
;
		PUBLIC IMGcopyW
IMGcopyW	PROC   imageBuf, imgPitch, backBuf, backPitch, x1, y1, x2, y2
		STARTPROC

		; ----- calc start of source and destination address ----;
		MOV	EAX, backBuf
		MOV	image_buf, EAX
		CALC_ADDR ESI, x1, y1, backPitch

		MOV	EAX, imageBuf		; store the address of the image buffer to a variable
		MOV	image_buf, EAX
		CALC_ADDR EDI, x1, y1, imgPitch	; Get the offset to the image buffer address

		;------ calc bar width and height -----;

		MOV     AX , DS
		MOV	ES , AX

		MOV     EBX, x2
		SUB	EBX, x1
		INC	EBX

		MOV	ECX, y2
		SUB	ECX, y1
		INC	ECX

		SUB	imgPitch,EBX		; lineDiff = image_width - 2 * icon_width
		SUB	backPitch,EBX		; lineDiff = image_width - 2 * icon_width
		SUB	imgPitch,EBX
		SUB	backPitch,EBX

		CLD                              ; clear direction flag for MOVSB

		;------- pixels copying loop --------;

		MOV	EDX, ECX
		SHR	EBX,1
		JC	@@putLineOdd

		ALIGN	4
@@putLineEven:
		MOV	ECX, EBX
		REP MOVSD
		ADD	ESI, backPitch
		ADD	EDI, imgPitch
		DEC	EDX
		JNZ	@@putLineEven
		JMP	@@end

		ALIGN	4
@@putLineOdd:
		MOV	ECX, EBX
		REP MOVSD
		MOVSW
		ADD	ESI, backPitch
		ADD	EDI, imgPitch
		DEC	EDX
		JNZ	@@putLineOdd
		;JMP	@@end

@@end:          ENDPROC
IMGcopyW	ENDP


;---------- END OF FUNCTION IMGcopyW ------------

END
