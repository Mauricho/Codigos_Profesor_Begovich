; Consigna: 
; Se espera a que se apriete el interruptor conectado al puerto E en el bit 0.
; (Interruptor con lógica positiva)
; Que saca 0xF0 por el puerto D durante 200[mS]
; Y saca 0x0F por el puerto D durante 200[mS]
; Y esta última tarea se repite de forma indefinida
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
	    
	    CLRF TRISD	    ;Salida por el puerto D

	    BCF STATUS, RP0 ;Banco 0
	    
;ESPERAR1    BTFSS PORTE,0
;	    GOTO ESPERAR1
	    CALL T25MS	    ;Si detecta 1 espera 25mS, tenemos en cuenta este ciclo
;ESPERAR2    BTFSC PORTE,0
;	    GOTO ESPERAR2   
;	    CALL T25MS	    ;Si detecta 0 espera 25mS, tenemos en cuenta este ciclo
	    
	    MOVLW 0XF0
	    MOVWF PORTD
REPETIR	    CALL T200MS	    ; tenemos en cuenta este ciclo
	    SWAPF PORTD,F
	    GOTO REPETIR
	    
T25MS	    MOVLW .3	    ;Var3
	    MOVWF 0X64
	    MOVLW .47	    ;Var2
	    MOVWF 0X65
	    MOVLW .25	    ;Var1
	    MOVWF 0X66
	    CALL ST3V
	    RETURN	    ; tenemos en cuenta este ciclo

T200MS	    MOVLW .243	    ;Var2
	    MOVWF 0X61
	    MOVLW .117	    ;Var1
	    MOVWF 0X62
	    CALL ST2V
	    RETURN	    ; tenemos en cuenta este ciclo
	    
; ********** Subrutina de tiempo de 3 variables ***********************
	    
ST3V	    MOVF 0X66,W
	    MOVWF 0X67
RECARGA3V   MOVF 0X65,W
	    MOVWF 0X68
DECRE3V	    NOP
	    NOP
	    NOP
	    NOP
	    DECFSZ 0X68,F
	    GOTO DECRE3V
	    DECFSZ 0X67,F
	    GOTO RECARGA3V
	    DECFSZ 0X64,F
	    GOTO ST3V
	    RETURN
	    
; ********** Subrutina de tiempo de 2 variables ***********************
	    
ST2V	    MOVF 0X62,W
	    MOVWF 0X63
DECRE2V	    NOP
	    NOP
	    NOP
	    NOP
	    DECFSZ 0X63,F
	    GOTO DECRE2V
	    DECFSZ 0X61,F
	    GOTO ST2V
	    RETURN
	       
	    END



