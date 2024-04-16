; Consigna:
; Hacer un contador de 0 a F con intervalos de tiempo de 1 segundo entre cada
; dígito.
; El puerto que controla el display es el puerto D.
; El display es cátodo común, para encender el display se debe escribir 1 en el 
; puerto A en el bit 0.
	    
	    LIST P=16F887
	    include <p16f887.inc>
	    include <Macros.inc>
	    
	    __config 0x2007,23E4
	    __config 0x2008,3FFF
	    
CONTA       EQU			0x20
	    
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
	    
	    CLRF		TRISD
	    BCF			TRISA,0
	    
	    BCF			STATUS,RP0
	    
	    BSF			PORTA,0		;Saco 1 por el puerto A
	    CLRF		CONTA		;Limpio conta	
	    
REP	    MOVF		CONTA,W
	    CALL		SIETESEG
	    MOVWF		PORTD		;Saco lo que tenga W por PORTD
	    SUBT3V		.203,.234,.3	;Espero un segundo
	    INCF		CONTA,F
	    MOVLW		0X0F
	    ANDWF		CONTA,F
	    GOTO		REP
	    
;******************************* Tabla *****************************************
;   Ejemplo para cargar el PCLATH antes de movernos:
	    ORG			0X0700
	    
SIETESEG    MOVWF		0X21		;Guardamos lo que hay en W
	    MOVLW		0X07
	    MOVWF		PCLATH		;Cargamos PCLATH
	    MOVF		0X21,W		;Recuperamos lo que hay en W
	    
	    ADDWF		PCL,F		;PC = PCLATH + CONTA + PCL
	    DT 0X3F,0X06,0X5B,0X4F,0X66,0X6D,0X7D,0X07,0X7F,0X6F,0X77,0X7C,0X39,0X5E,0X79,0X71
	    
	    ;END al final del archivo
	    
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
