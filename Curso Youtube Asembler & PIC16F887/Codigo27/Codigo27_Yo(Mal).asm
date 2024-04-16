; Consigna:
; Hacer un contador de 0 a 99 con una duración de 1 segundo entre cada número.
; Utilizar dos display de 7 segmentos, cátodo común.
	    
	    LIST P=16F887
	    include <p16f887.inc>
	    include <Macros.inc>
	    
	    __config 0x2007,23E4
	    __config 0x2008,3FFF
	    
	    #DEFINE	    DECENASON		BSF	PORTB,1
	    #DEFINE	    DECENASOFF		BCF	PORTB,1
	    #DEFINE	    UNIDADESON		BSF	PORTB,0
	    #DEFINE	    UNIDADESOFF		BCF	PORTB,0

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
	    BCF			TRISB,0
	    BCF			TRISB,1
	    
	    BCF			STATUS,RP0
	    
	    CLRF		SESENTA
	    CLRF		DECENAS
	    CLRF		UNIDADES
	    
REP	    MOVF		DECENAS,W
	    
	    CALL		SIETESEG    ;Cargo W con la tabla
	    UNIDADESOFF			    ;%%%	
	    MOVWF		PORTD
	    DECENASON
	    SUBT3V		.2,.84,.7   ;Demoro 8333 [uS]		    ;---
	    NOP
	    
	    MOVF		UNIDADES,W
	    
	    CALL		SIETESEG    ;Cargo W con la tabla
	    DECENASOFF			    ;---
	    MOVWF		PORTD
	    UNIDADESON
	    SUBT3V		.213,.5,.1  ;Demoro 8333 [uS]		    ;%%%
	    
	    INCF		SESENTA,F
	    
	    MOVF		SESENTA,W
	    XORLW		.60
	    BTFSS		STATUS,Z
	    GOTO		REP
	    
	    CLRF		SESENTA
	    
	    INCF		UNIDADES,F
	    
	    MOVF		UNIDADES,W
	    XORLW		0X0A
	    BTFSS		STATUS,Z
	    GOTO		REP
	    
	    CLRF		UNIDADES
	    
	    INCF		DECENAS,F
	    
	    MOVF		DECENAS,W
	    XORLW		0X0A
	    BTFSS		STATUS,Z
	    GOTO		REP
	    
	    CLRF		DECENAS
	    
	    GOTO		REP
	   	    
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
	    
;SUBT25MS    ;Se agrega porque el programa la llama mediante una macro que utiliza T25MS
	    ; entonces aquí llamamos a la macro que implementa el T25MS
	    
	    END
