; Consigna:
; Se desea sacar por el puerto D un PWM con frecuencia de 1 KHz cada vez que se apriete 
; el bit 0 del puerto E, se debe cambiar el PWM:
; a). 0% a 5%
; b). 5% a 20%
; c). 20% a 50%
; d). 50% a 80%
; e). 80% a 0% y vuelve a comenzar
; Mostrar en el bit 2 del puerto E siempre 1.
;Archivo con las macros:
	    
	    LIST P=16F887
	    include <p16f887.inc>
	    include <macros.inc>
	    
	    __config 0x2007,23E4
	    __config 0x2008,3FFF

	    ORG 		0X0000
		
	    CLRF 		PORTA
	    CLRF 		PORTB
	    CLRF		PORTC
	    CLRF 		PORTD
	    CLRF		PORTE
	
	    BSF			STATUS,RP0
	    BSF			STATUS,RP1
	
	    CLRF 		ANSEL
	    CLRF		ANSELH
	
	    BCF			STATUS,RP1
		
	    CLRF		TRISD	;Salida por el puerto D
	    BCF			TRISE,2	;Salida por el pin 2 del puerto E
		
	    BCF 		STATUS,RP0
		
INICIO:	    CALL		TESTPE0

PWM5:	    COMF		PORTD,F	;Se cambia a 1
	    SUBT3V		.2,.2,.1				;50uS
	    COMF		PORTD,F	;Se cambia a 0
	    SUBT2V		.9,.14					;950uS
		
	    BTFSS		PORTE,0
	    GOTO		PWM5
		
	    CALL		TESTPE0
		
PWM20:	    COMF		PORTD,F	;Se cambia a 1
	    SUBT2V		.4,.6					;200uS
	    COMF		PORTD,F	;Se cambia a 0
	    SUBT2V		.37,.3					;800uS
		
	    BTFSS		PORTE,0
	    GOTO		PWM20
		
	    CALL		TESTPE0

PWM50:	    COMF		PORTD,F	;Se cambia a 1
	    SUBT2V		.17,.4					;500uS
	    COMF		PORTD,F	;Se cambia a 0
	    SUBT1V		.70					;500uS
	    NOP

	    BTFSS		PORTE,0
	    GOTO		PWM50
		
	    CALL		TESTPE0

PWM80:	    COMF		PORTD,F	;Se cambia a 1
	    SUBT2V		.1,.72					;800uS
	    COMF		PORTD,F	;Se cambia a 0
	    SUBT1V		.27					;200uS
	    NOP
	    NOP
		
	    BTFSS		PORTE,0
	    GOTO		PWM80
		
	    CALL		TESTPE0
		
	    CLRF 		PORTD	;Limpiamos el puerto D
							
	    GOTO 		INICIO	

TESTPE0:    PUSH_ANTIR		PORTE,0	;Elimino los rebotes del puerto E 0
	    RETURN

;   Subrutina de tiempo de una (1) variable
ST1V	NOP
	NOP
	NOP
        NOP
        DECFSZ 0X60,F
        GOTO ST1V
        RETURN

;   Subrutina de tiempo de dos (2) variables
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
	        
;   Subrutina de tiempo de tres (3) variables
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

SUBT25MS    ;Se agrega porque el programa la llama mediante una macro que utiliza T25MS
	    ; entonces aquí llamamos a la macro que implementa el T25MS

	    END
