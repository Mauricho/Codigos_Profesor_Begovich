; Consigna: Leer el puerto B y el puerto C. Si PB es mayor o igual que PC debe salir 0xAB por PD.
; Si PB es menor que PC debe salir 0xC5 por el puerto D.
	    LIST P=16F887
	    #include p16f887.inc

	    __config 0x2007,23E4
	    __config 0x2008,3FFF

	    org 0x00

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

	    CLRF TRISD	    ;Salida por el puerto D

	    BCF STATUS, RP0 ;Banco 0
    
REPETIR	    MOVF PORTC,W
	    SUBWF PORTB,W
	    MOVLW 0XC5
	    BTFSC STATUS,C
	    MOVLW 0xAB
	    MOVWF PORTD
	   
	    GOTO REPETIR
	    
	    END
    
    



