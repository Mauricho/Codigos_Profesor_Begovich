; Consigna: Leer el nibble bajo del puerto C y sacar ese valor por el nibble 
; alto del puerto D. Leer el nibble alto del puerto B y sacar ese valor como 
; el nibble bajo del puerto D.
	    
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
    
REPETIR	    MOVF PORTC,W    ;Corregido
	    ANDLW 0X0F
	    MOVWF 0x20	    ;PORTD
	    MOVF PORTB,W
	    ANDLW 0XF0
	    IORWF 0x20,F    ;PORTD,F
	    SWAPF 0x20,F    ;PORTD,F
	    MOVF 0X20,W
	    MOVWF PORTD
	    
	    GOTO REPETIR
	    
	    END
    
    



