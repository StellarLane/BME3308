ORG 0000H
	LJMP MAIN
ORG 0013H
	LJMP IN11

MAIN: 
	SETB 	EA
	SETB 	EX1
	CLR		PX1	
	SETB	IT1
	MOV 	A,	#01H
	SJMP $

IN11:
	RL A
	MOV P1, A
	RETI
	
END
	