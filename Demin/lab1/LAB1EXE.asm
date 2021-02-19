AStack    SEGMENT  STACK
          DW 64 DUP(?)    ; Žâ¢®¤¨âáï 12 á«®¢ ¯ ¬ïâ¨
AStack    ENDS	
	
DATA SEGMENT

STRING_PC db 'PC',0DH,0AH,'$'
STRING_PC_XT db 'PC/XT',0DH,0AH,'$'
STRING_AT db 'AT',0DH,0AH,'$'
STRING_PS2_30 db 'PS2 модель 30',0DH,0AH,'$'
STRING_PS2_80 db 'PS2 модель 80',0DH,0AH,'$'
STRING_PCjr db 'PCjr',0DH,0AH,'$'
STRING_PC_CON db 'PC Convert	ible',0DH,0AH,'$'
STRING_IMB db 'IBM_PC:','$'
STRING_ANOTHER	db	'  ',0DH,0AH,'$'
STRING_VERSION_DOS	db	' .    ',0DH,0AH,'$'
STRING_VERSION_DOS_TEXT	db	'MS DOS: ','$'
STRING_0 db '<2.0',0DH,0AH,'$'
STRING_OEM_TEXT db 'OEM: ', '$'
STRING_OEM db	' ',0DH,0AH,'$'
STRING_USER_TEXT db 'User Serial Number: ', '$'
STRING_USER db	'      ',0DH,0AH,'$'

DATA ENDS

CODE 	SEGMENT
		ASSUME CS:CODE, DS:DATA, SS:AStack
		
PRINT PROC near
    mov	AH,	09h             ;Номер функции 09h
	int	21h
	ret
PRINT ENDP

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
;-------------------------------

Main      PROC  FAR
	  push  DS      
	  sub   AX,AX    
	  push  AX       
	  mov   AX,DATA            
	  mov   DS,AX
ibm_pc:
	mov DX,offset STRING_IMB
	call PRINT
	

    MOV AX,0F000H ;указывает ES на ПЗУ
	MOV ES,AX ;
	MOV AL,ES:[0FFFEH] ;получаем байт
	
	CMP AL,0FEH
	je PC_XT
	CMP AL,0FBH
	je PC_XT
	CMP AL,0FCH 
	je vAT
	CMP AL,0FAH 
	je PS2_30
	CMP AL,0F8H
	je PS2_80
	CMP AL,0FDH
	je PCjr
	CMP AL,0F9H
	je PC_CON
	CMP AL,0FFH 
	je PC
	
	
	
	
	jmp Another
	
PC:
	mov DX, offset STRING_PC
	jmp PRINT_IBM_PC
	
PC_XT: 		
	mov DX, offset STRING_PC_XT
	jmp PRINT_IBM_PC
	
vAT:		
	mov DX,offset  STRING_AT
	jmp PRINT_IBM_PC
	
PS2_30:	
	mov DX,offset  STRING_PS2_30
	jmp PRINT_IBM_PC
	
PS2_80:	
	mov DX,offset STRING_PS2_80
	jmp PRINT_IBM_PC
	
PCjr:	
	mov DX,offset STRING_PCjr
	jmp PRINT_IBM_PC
	
PC_CON:
	mov DX,offset STRING_PC_CON
	jmp PRINT_IBM_PC
Another:
	call BYTE_TO_HEX
	mov	si, offset STRING_ANOTHER
	add	si, 1
	mov	[si], ax
	mov dx,offset STRING_ANOTHER
	
PRINT_IBM_PC:
	call PRINT
	
MS_DOS:
	mov dx, offset STRING_VERSION_DOS_TEXT
	call PRINT
	MOV AH,30h
	INT 21h
	cmp AL,0
	je NULL_VERSION
	mov	si, offset STRING_VERSION_DOS
	call BYTE_TO_DEC
	add si,3
	mov AL,AH
	call BYTE_TO_DEC
	MOV dx,offset STRING_VERSION_DOS
	call PRINT
	jmp OEM
NULL_VERSION:
	mov dx, offset STRING_0
	call PRINT
OEM:
	mov dx,offset STRING_OEM_TEXT
	call PRINT
	mov AL,BH
	mov si,offset STRING_OEM
	call BYTE_TO_DEC
	mov dx, offset STRINg_OEM
	call PRINT
USER_SERIES:
	mov dx,offset STRING_USER_TEXT
	call PRINT
	mov	 si, offset STRING_USER
	mov al, bl
	call byte_to_hex
	mov [si], ax
	add si, 2
	mov al, ch
	call byte_to_hex
	mov [si], ax
	add si, 2
	mov al, cl
	call byte_to_hex
	mov [si], ax
	mov dx, offset STRING_USER
	call PRINT
    xor AL,AL
    mov AH,4Ch
    int 21H
    ret                      
Main      ENDP
CODE      ENDS
          END Main