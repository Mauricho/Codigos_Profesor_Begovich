; Consigna:
; Hacer un semaforo.
	    
	    LIST P=16F887
	    include <p16f887.inc>
	    include <Macros.inc>
	    include <Def_Semaforo.inc>
	    
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
		
	    MOVLW		B'11111000' ; ponemos algunos bits como salida
	    MOVWF		TRISD	    ; solo los bit 0,1,2
	    MOVWF		TRISE	    ; solo los bit 0,1,2
	    
	    BCF			STATUS,RP0
	    
INICIO	    R1_A
	    V1_E
	    R2_E
	    
	    CALL		T30S		;Dura 30 segundos
	    
	    V1_A
	    
	    MOVLW		.5
	    MOVWF		0X20
	    
PARP1	    A1_E
	    
	    CALL		T600MS		;Dura 0.6 segundos
	    
	    A1_A		  
	    
	    CALL		T600MS		;Dura 0.6 segundos
	    
	    DECFSZ		0X20,F		;Repetimos 5 veces PARP1 
	    GOTO		PARP1
	    
	    R2_A
	    V2_E
	    R1_E
	    
	    CALL		T30S		;Dura 30 segundos
	    
	    V2_A
	    
	    MOVLW		.5
	    MOVWF		0X20		;Recargamos el registro 20
	    
PARP2	    A2_E
	    
	    CALL		T600MS		;Dura 0.6 segundos
	    
	    A2_A		  
	    
	    CALL		T600MS		;Dura 0.6 segundos
	    
	    DECFSZ		0X20,F
	    GOTO		PARP2
	    
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
	    
;SUBT25MS    ;Se agrega porque el programa la llama mediante una macro que utiliza T25MS
	    ; entonces aquí llamamos a la macro que implementa el T25MS
	    
	    END