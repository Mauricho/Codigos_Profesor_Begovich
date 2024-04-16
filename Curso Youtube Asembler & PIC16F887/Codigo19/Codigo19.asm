; Consigna:
; Hacer una secuencia de sonidos, cambiando de sonido cada vez que se 
; apriete un interruptor conectado al puerto E, pin 0.
; El sonido debe salir por el puerto E, pin 1.
; Las frecuencias son: 330 [Hz], 262 [Hz], 392 [HZ], 192 [Hz]
	    
	    LIST P=16F887
	    include <p16f887.inc>
	    include <Macros.inc>
	    
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
		
	    BCF			TRISE,1	  ;La señal sale por el puerto E, bit 1
	    
	    BCF			STATUS,RP0
	    
INICIO	    PUSH_ANTIR		PORTE,0
	    
F1	    BSF			PORTE,1
	    SUBT2V		.1,.137     ;1515	
	    BCF			PORTE,1
	    SUBT2V		.4,.47	    ;1515	
	    
	    BTFSS		PORTE,0
	    GOTO		F1
	    
	    PUSH_ANTIR		PORTE,0
	    
F2	    BSF			PORTE,1
	    SUBT2V		.3,.76      ;1908	
	    BCF			PORTE,1
	    SUBT3V		.1,.53,.5   ;1908	
	    
	    BTFSS		PORTE,0
	    GOTO		F2
	    
	    PUSH_ANTIR		PORTE,0	    
	    
F3	    BSF			PORTE,1
	    SUBT3V		.1,.35,.5   ;1275	
	    BCF			PORTE,1
	    SUBT2V		.22,.8	    ;1275	
	    
	    BTFSS		PORTE,0
	    GOTO		F3
	    
	    PUSH_ANTIR		PORTE,0

F4	    BSF			PORTE,1
	    SUBT2V		.1,.236     ;2604	
	    BCF			PORTE,1
	    SUBT2V		.2,.144      ;2604	
	    NOP
	    
	    BTFSS		PORTE,0
	    GOTO		F4
	    
	    GOTO		INICIO


	    
;*********************** Subrutinas ********************************************
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

;   Subrutina de tiempo de 30 Segundos
T30S	    SUBT3V  .96,.211,.211
	    RETURN
	    
;   Subrutina de tiempo de 30 Segundos
T600MS	    SUBT3V  .247,.49,.7
	    RETURN
	    
SUBT25MS    ;Se agrega porque el programa la llama mediante una macro que utiliza T25MS
	    ; entonces aquí llamamos a la macro que implementa el T25MS
	    
	    END