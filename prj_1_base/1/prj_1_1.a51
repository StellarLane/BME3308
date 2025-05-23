ORG 0000H
LJMP INIT

ORG 0100H
	INIT:
	MOV SCON, #50H
	MOV TMOD, #20H
	MOV TH1, #0FDH
	MOV TL1, #0FDH
	SETB TR1
	SETB ES
	SETB EA

	START:
	MOV DPTR, #0000H
	MOVX @DPTR, A
	MOVX A, @DPTR
	MOV 30H, A
	JMP NEXT
	
	NEXT:
	MOV A, 30H
	MOV B, #02H
	MUL AB
	MOV B, #02H
	SUBB A, B
	LCALL SEND_TMP
	MOV B, #10
	DIV AB
	PUSH B
	MOV B, #10
	DIV AB
	PUSH B
	MOV B, #10
	DIV AB
	MOV A, B
	
	N30:
	ADD A, #02
	CJNE A, #0, N31
	MOV R2, #11000000B
	JMP N20
	N31:
	CJNE A, #1, N32
	MOV R2, #11001111B
	JMP N20
	N32:
	CJNE A, #2, N33
	MOV R2, #10100100B
	JMP N20
	N33:
	CJNE A, #3, N34
	MOV R2, #10110000B
	JMP N20
	N34:
	CJNE A, #4, N35
	MOV R2, #10011001B
	JMP N20
	N35:
	CJNE A, #5, N36
	MOV R2, #10010010B
	JMP N20
	N36:
	CJNE A, #6, N37
	MOV R2, #10000010B
	JMP N20
	N37:
	CJNE A, #7, N38
	MOV R2, #11111000B
	JMP N20
	N38:
	CJNE A, #8, N39
	MOV R2, #10000000B
	JMP N20
	N39:
	MOV R2, #10010000B
	
	
	N20:
	POP B
	MOV A, B
	CJNE A, #0, N21
	MOV R3, #01000000B
	JMP N10
	N21:
	CJNE A, #1, N22
	MOV R3, #01001111B
	JMP N10
	N22:
	CJNE A, #2, N23
	MOV R3, #00100100B
	JMP N10
	N23:
	CJNE A, #3, N24
	MOV R3, #00110000B
	JMP N10
	N24:
	CJNE A, #4, N25
	MOV R3, #00011001B
	JMP N10
	N25:
	CJNE A, #5, N26
	MOV R3, #00010010B
	JMP N10
	N26:
	CJNE A, #6, N27
	MOV R3, #00000010B
	JMP N10
	N27:
	CJNE A, #7, N28
	MOV R3, #01111000B
	JMP N10
	N28:
	CJNE A, #8, N29
	MOV R3, #00000000B
	JMP N10
	N29:
	MOV R3, #00010000B
	
	
	N10:
	POP B
	MOV A, B
	CJNE A, #0, N11
	MOV R4, #11000000B
	JMP LOOOP
	N11:
	CJNE A, #1, N12
	MOV R4, #11001111B
	JMP LOOOP
	N12:
	CJNE A, #2, N13
	MOV R4, #10100100B
	JMP LOOOP
	N13:
	CJNE A, #3, N14
	MOV R4, #10110000B
	JMP LOOOP
	N14:
	CJNE A, #4, N15
	MOV R4, #10011001B
	JMP LOOOP
	N15:
	CJNE A, #5, N16
	MOV R4, #10010010B
	JMP LOOOP
	N16:
	CJNE A, #6, N17
	MOV R4, #10000010B
	JMP LOOOP
	N17:
	CJNE A, #7, N18
	MOV R4, #11111000B
	JMP LOOOP
	N18:
	CJNE A, #8, N19
	MOV R4, #10000000B
	JMP LOOOP
	N19:
	MOV R4, #10010000B
	
	LOOOP:
	MOV P2, #00010010B
	MOV P1, R2
	MOV P1, #11111111B
	MOV P2, #00010100B
	MOV P1, R3
	MOV P1, #11111111B
	MOV P2, #00011000B
	MOV P1, R4
	MOV P1, #11111111B
	LJMP START
	
	SEND_TMP:
	MOV SBUF, A
	JNB TI, $
	CLR TI
	RET
	
	
END