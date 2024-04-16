; Leer el valor del puerto B y sacar ese valor por el puerto C
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

	    CLRF TRISC	    ;Salida por el puerto C

	    BCF STATUS, RP0 ;Banco 0
    
REPETIR	    MOVF PORTB,W   ;PORTB -->   W
	    ADDLW 0x54	   ;Sumo 0x54 al puerto B
	    MOVWF PORTC	   ;  W   --> PORTC
	    GOTO REPETIR
	    
	    END
    
    



