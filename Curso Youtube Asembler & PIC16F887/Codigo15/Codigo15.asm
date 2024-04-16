; Consigna: 
; Se espera a que se apriete el interruptor conectado al puerto E en el bit 0.
; (Interruptor con lógica positiva)
; Que saca 0xF0 por el puerto D durante 200[mS]
; Y saca 0x0F por el puerto D durante 200[mS]
; Y esta última tarea se repite de forma indefinida
	    
;Archivo con las macros:
	    
	    LIST P=16F887
	    include <p16f887.inc>
	    include <macros.inc>
	    
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

	    PUSH_ANTIR PORTE,0	;Llamo a una macro para eliminar el antirrebote
	    
	    MOVLW 0XF0
	    MOVWF PORTD
REPETIR	    SUBT3V  .73,.35,.11	;Llamo a una macro demorar 200[ms]
	    SWAPF PORTD,F
	    GOTO REPETIR
	    
T25MS	    SUBT3V  .25,.47,.3	;Llamos a una macro demorar 25[ms]
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
	    
	    END