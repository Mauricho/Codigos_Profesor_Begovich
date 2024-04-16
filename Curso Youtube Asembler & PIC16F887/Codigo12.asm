; Consigna: Leer el bit 0 del puerto B:
; Si es 0, sacar 0xF5 por el puerto D
; Si es 1, sacar 0x24 por el puerto D
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
	    
	    CLRF TRISA	    ;Salida por el puerto A
	    CLRF TRISD	    ;Salida por el puerto D

	    BCF STATUS, RP0 ;Banco 0
    
REPETIR	    MOVLW 0X24
	    BTFSS PORTB,0
	    MOVLW 0XF5
	    MOVWF PORTD
	    
	    GOTO REPETIR
	    
	    END
    
    



