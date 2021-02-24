	TESTPC SEGMENT
    ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
	ORG 100H
    START: JMP BEGIN
	SEGMENT_ADDRESS_TEXT db 'segment address of inaccessible memory:',  '$'
	SEGMENT_ADDRESS db '    ', 0DH, 0AH, '$'
	E_SEGMENT_ADDRESS_TEXT db 'environment segment address',  '$'
	E_SEGMENT_ADDRESS db '    ', 0DH, 0AH, '$'
	TAIL_TEXT db 'TAIL:','$'
	EAREA_TEXT db 'Environment area content:', '$'
	NEXT_LINE db '       ',0DH, 0AH, '$'
	PATH db'loadable module path:', '$'


PRINT PROC near
    mov	AH,	09h             ;Ќ®¬Ґа дг­ЄжЁЁ 09h
	int	21h
	ret
PRINT ENDP

PRINT_BYTE PROC near
	int	29h
	ret
PRINT_BYTE ENDP

TETR_TO_HEX PROC near
    and AL, 0Fh
    cmp AL, 09
    jbe NEXT
    add AL, 07
NEXT: add AL, 30h
    ret
TETR_TO_HEX ENDP
;-------------------------------
BYTE_TO_HEX PROC near
;byte AL translate in two symbols on 16cc numbers in AX
    push CX
    mov AH,AL
    call TETR_TO_HEX
    xchg AL,AH
    mov CL, 4
    shr AL,CL
    call TETR_TO_HEX
    pop CX
ret
BYTE_TO_HEX ENDP
;-------------------------------
WRD_TO_HEX PROC near
;translate in 16cc a 16 discharge number
;in AL - number, DI - the address of the last symbol  
    push BX
    mov BH,AH
    call BYTE_TO_HEX
    mov [DI],AH
    dec DI
    mov [DI],AL
    dec DI
    mov AL,BH
    call BYTE_TO_HEX
    mov [DI],AH
    dec DI
    mov [DI],AL
    pop BX
ret
WRD_TO_HEX ENDP
;--------------------------------------------------
BYTE_TO_DEC PROC near
;translate in 10cc, SI - the adress of the field of younger digit
    push CX
    push DX
    xor AH,AH
    xor DX,DX
    mov CX,10
loop_bd: div CX
    or DL,30h
    mov [SI],DL
    dec SI
    xor DX,DX
    cmp AX,10
    jae loop_bd
    cmp AL,00h
    je end_l
    or AL,30h
    mov [SI],AL
end_l: pop DX
    pop CX
ret
BYTE_TO_DEC ENDP


SEGMENT_ADDRESS_VOID PROC near
			mov DX, offset SEGMENT_ADDRESS_TEXT
			call PRINT
			mov AX, DS:[02h]
			mov DI, offset SEGMENT_ADDRESS
			add DI,4
			call WRD_TO_HEX
			mov DX, offset SEGMENT_ADDRESS
			call PRINT
			ret
SEGMENT_ADDRESS_VOID ENDP

E_SEGMENT_ADDRESS_VOID PROC near
			mov DX, offset E_SEGMENT_ADDRESS_TEXT
			call PRINT
			mov AX, DS:[2Ch]
			mov DI, offset E_SEGMENT_ADDRESS
			add DI,4
			call WRD_TO_HEX
			mov DX, offset E_SEGMENT_ADDRESS
			call PRINT
			ret
E_SEGMENT_ADDRESS_VOID ENDP

TAIL_VOID PROC near
			mov dx, offset TAIL_TEXT
			call PRINT
			sub cx,cx
			mov cl,ds:[80h]
			sub ax,ax
	 		sub bx,bx
			cmp cl,0
			je exit
		metka:
			mov al,ds:[81h+bx]
			inc bx	
			call PRINT_BYTE
			loop metka 	
		exit:
		mov dx,offset NEXT_LINE
		call PRINT
			ret
TAIL_VOID ENDP

PRINT_EAREA PROC near
	mov ax,cs
	mov ds,ax
	mov dx,offset NEXT_LINE
	call PRINT
	
	mov ax,es
	mov ds,ax
	writeLoop:
	mov al,ds:[bx]
	inc bx
	cmp al,0
	je exit_pr_ea
	call PRINT_BYTE

	loop writeLoop
	exit_pr_ea:
	ret

PRINT_EAREA ENDP

EAREA_VOID  PROC near
	mov dx, offset EAREA_TEXT
	call PRINT
	mov ax, ds:[2Ch]
	mov ds,ax
	mov es, ax
	sub bx,bx
	call PRINT_EAREA
	call PRINT_EAREA
	call PRINT_EAREA	
	add bx,3
	
	mov ax,cs
	mov ds,ax
	mov dx,offset NEXT_LINE
	call PRINT

	mov dx,offset PATH
	call PRINT
	
	call PRINT_EAREA
	ret
EAREA_VOID ENDP

BEGIN:
	call SEGMENT_ADDRESS_VOID
	call E_SEGMENT_ADDRESS_VOID
	call TAIL_VOID
	call EAREA_VOID
      
	xor AL,AL
	mov AH,4Ch
	int 21H
    int 21H
TESTPC    ENDS
          END START