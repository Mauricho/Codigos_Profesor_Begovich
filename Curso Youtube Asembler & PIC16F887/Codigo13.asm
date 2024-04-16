; Consigna: 
; *Si el puerto B bit 7 == 0 y el puerto C bit 3 == 0
; El puerto D debe sacar 0xF3 y el puerto A debe sacar 0x89
; *Si el puerto B bit 7 == 0 y el puerto C bit 3 == 1
; El puerto D debe sacar 0x45 y el puerto A debe sacar 0x7C
;*Si el puerto B bit 7 == 1 y el puerto C bit 3 == 0
; El puerto D debe sacar 0x94 y el puerto A debe sacar 0x42
; *Si el puerto B bit 7 == 1 y el puerto C bit 3 == 1
; El puerto D debe sacar 0xFF y el puerto A debe sacar 0xDE
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
    
REPETIR	    BTFSS PORTB,7
	    GOTO B70
	    GOTO B71

B70	    BTFSS PORTC,3
	    GOTO B70C30
	    GOTO B70C31

B71	    BTFSS PORTC,3
	    GOTO B71C30
   	    GOTO B71C31

B70C30	    MOVLW 0XF3
	    MOVWF PORTD
	    MOVLW 0X89
	    MOVWF PORTA
	    GOTO REPETIR

B70C31	    MOVLW 0X45
	    MOVWF PORTD
	    MOVLW 0X7C
	    MOVWF PORTA
	    GOTO REPETIR

B71C30	    MOVLW 0X94
	    MOVWF PORTD
	    MOVLW 0X42
	    MOVWF PORTA
	    GOTO REPETIR

B71C31	    MOVLW 0XFF
	    MOVWF PORTD
	    MOVLW 0XDE
	    MOVWF PORTA
	    GOTO REPETIR
	    
	    END



