; Consigna: Leer el puerto B y el puerto C. 
;	    Si PB > PC, el PD debe sacar 0x12 y el PA debe sacar 0XCC
;	    Si PB < PC, el PD debe sacar 0x69 y el PA debe sacar 0x7B
;	    Si PB = PC, el PD debe sacar 0xE1 y el PA debe sacar 0xDD
	    
	    LIST P=16F887
	    #include p16f887.inc

	    __config 0x2007,23E4
	    __config 0x2008,3FFF

	    ORG 0x00

	    CLRF PORTA
	    CLRF PORTB
	    CLRF PORTC
	    CLRF PORTD
	    CLRF PORTE

	    BSF STATUS, RP0
	    BSF STATUS, RP1 ;Banco 3

	    CLRF ANSEL
	    CLRF ANSELH	    ;Puerto A y B son digitales

	    BCF STATUS, RP1 ;Banco 1
	    
	    CLRF TRISA
	    CLRF TRISD	    ;Salida por el puerto D

	    BCF STATUS, RP0 ;Banco 0
    
REPETIR	    MOVF PORTC,W
	    SUBWF PORTB,W
	    
	    BTFSC STATUS,Z  
	    
	    GOTO IGUALES
	    
	    BTFSS STATUS,C  
	    
	    GOTO B_MENOR
	    
	    MOVLW 0X12
	    MOVWF PORTD
	    MOVLW 0XCC
	    MOVWF PORTA
	    
	    GOTO REPETIR

B_MENOR	    MOVLW 0X69
	    MOVWF PORTD
	    MOVLW 0X7B
	    MOVWF PORTA
	    
	    GOTO REPETIR
	    
IGUALES	    MOVLW 0XE1
	    MOVWF PORTD
	    MOVLW 0XDD
	    MOVWF PORTA
	    
	    GOTO REPETIR
	    
	    END
    
    



