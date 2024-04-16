; Consigna: Leer el puerto B y el puerto C. 
;	    Si PB <= PC, el PD debe sacar 0xDF y el PA debe sacar 0X8F.
;	    Si PB > PC, el PD debe sacar 0x34 y el PA debe sacar 0x6A
	    
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
	    
	    CLRF TRISA
	    CLRF TRISD	    ;Salida por el puerto D

	    BCF STATUS, RP0 ;Banco 0
    
REPETIR	    MOVF PORTB,W
	    SUBWF PORTC,W   ;PORTC -PORTB
	    BTFSS STATUS,C
	    GOTO PC_MENOR   ;PORTC <= PORTB
	    MOVLW 0XDF	    ;PORTC > PORTB
	    MOVWF PORTD
	    MOVLW 0X8F
	    MOVWF PORTA
	    
	    GOTO REPETIR
	    
PC_MENOR    MOVLW 0X34
	    MOVWF PORTD
	    MOVLW 0X6A
	    MOVWF PORTA
	   
	    GOTO REPETIR
	    
	    END
    
    



