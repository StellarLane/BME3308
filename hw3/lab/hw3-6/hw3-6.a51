ORG 0000H
LJMP START

TABLE: DB 0x12, 0x34, 0x56

START:
    MOV DPTR, #TABLE      
    MOV A, #01H          
    MOVC A, @A+DPTR     
	MOV R0, #100          
	DELAY: 
    DJNZ R0, DELAY  
    ;MOV DPTR, #2000H     
    ;MOVX @DPTR, A        
	;SJMP START        
END
