; Consigna:
; Hacer un contador de 0 a 99 con una duración de 1 segundo entre cada número.
; Utilizar dos display de 7 segmentos, cátodo común.
	    
	    LIST P=16F887
	    include <p16f887.inc>
	    include <Macros.inc>
	    
	    __config 0x2007,23E4
	    __config 0x2008,3FFF
	    
	    #DEFINE	    DECENASON		BSF	PORTA,1
	    #DEFINE	    DECENASOFF		BCF	PORTA,1
	    #DEFINE	    UNIDADESON		BSF	PORTA,0
	    #DEFINE	    UNIDADESOFF		BCF	PORTA,0

UNIDADES    EQU			0x20
DECENAS	    EQU			0X21
SESENTA	    EQU			0X22
	    
	    ORG 		0X0000
	    
	    GOTO		INICIO
	    SIETESEGK		;Tabla para display 7 seg cátodo común
;	    SIETESEGA		;Tabla para display 7 seg ánodo común
	    
INICIO	    CLRF 		PORTA
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
	    BCF			TRISA,1
	    
	    BCF			STATUS,RP0
	    
LIMPIADEC   CLRF		DECENAS
LIMPIAUNI   CLRF		UNIDADES
	    
RECARGA60   MOVLW		.60
	    MOVWF		SESENTA		
	    
REP	    MOVF		UNIDADES,W
	    CALL		SIETESEG
	    MOVWF		PORTD	    ;Muestro el valor
	    UNIDADESON
	    CALL		T120AVO
	    UNIDADESOFF
	    
	    MOVF		DECENAS,W
	    CALL		SIETESEG
	    MOVWF		PORTD	    ;Muestro el valor
	    DECENASON			    ;---
	    CALL		T120AVO
	    DECENASOFF
						
	    DECFSZ		SESENTA,F   ;---
	    GOTO		REP	    ;Repito durante 1 seg
	    
	    INCF		UNIDADES,F
	    MOVLW		0X0A
	    XORWF		UNIDADES,W  ;Incrementa unidades y lo compara
	    
	    BTFSS		STATUS,Z    ;Si llega a 10 incrementa decena
	    GOTO		RECARGA60   ;caso contrario vuelve a empezar
	    
	    INCF		DECENAS,F
	    MOVLW		0X0A
	    XORWF		DECENAS,W   ;Incrementa decenas y lo compara
	    
	    BTFSS		STATUS,Z    ;Si llega a 10 vuelve a empezar
	    GOTO		LIMPIAUNI   ;caso contrario vuelve a empezar
	    
	    GOTO		LIMPIADEC
	   	    
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

;   Subrutina de tiempo de 1/120 [S]
T120AVO	    SUBT2V  .7,.157	 
	    RETURN
	    
;SUBT25MS    ;Se agrega porque el programa la llama mediante una macro que utiliza T25MS
	    ; entonces aquí llamamos a la macro que implementa el T25MS
	    
	    END
