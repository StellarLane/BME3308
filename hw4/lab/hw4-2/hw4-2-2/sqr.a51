?PR?SQR SEGMENT CODE
	RSEG 	?PR?SQR

ORG 1000H
	
	PUBLIC SQR
		
	SQR:
	MOV A, R5
	MOV B, A
	MUL AB
	MOV R0, A
	MOV R1, B
	MOV A, R7
	MOV B, A
	MUL AB
	MOV R2, B
	MOV B, R0
	ADD A, B
	MOV R7, A
	MOV A, R1
	MOV B, R2
	ADDC A, B
	MOV R6, A
	RET
	
END