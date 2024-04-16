; Consigna:
; (PB0 - PB3 se conectan a D4 - D7 de la LCD)
; "RS" se conecta a PB4 y "E" a RB5
; Imprime usando 4 bits de bus de datos las cadenas en la LCD:
; "Ensamblador para PIC16F887	    :) "
	    
	    LIST P=16F887
	    
	    include <p16f887.inc>
	    include <Macros.inc>
	    
	    #DEFINE	RS_0	BCF	PORTB,4	    ;RS en 0
    	    #DEFINE	RS_1	BSF	PORTB,4	    ;RS en 1
	    #DEFINE	E_0	BCF	PORTB,5	    ;E en 0
	    #DEFINE	E_1	BSF	PORTB,5	    ;E en 1
	    
DATO	EQU	0X2A
	
	    __config 0x2007,23E4
	    __config 0x2008,3FFF
	    
	    ORG 		0X0000
	    
	    GOTO		INICIO
	    
;	    SIETESEGK		;Tabla para display 7 seg cátodo común
;	    SIETESEGA		;Tabla para display 7 seg ánodo común
	    LCD_MACRO		;Tabla para LCD
	    
INICIO	    CLRF 		PORTA
	    CLRF 		PORTB
	    CLRF		PORTC
	    CLRF 		PORTD
	    CLRF		PORTE
	
	    BSF			STATUS,RP0
	    BSF			STATUS,RP1  ;Bank3
	
	    CLRF 		ANSEL
	    CLRF		ANSELH
	
	    BCF			STATUS,RP1  ;Bank1
	    
	    CLRF		TRISB
	    
	    BCF			STATUS,RP0  ;Bank0
	    
	    CALL		SALUDO	    ;Inicialización del LCD
	    
	    CLRF		0X20
T1	    MOVF		0X20,W
	    
	    CALL		TABLA_LCD   ;Regreso con el valor en W
	    
	    CALL		CARACTER    ;Escribo el caracter
	    
	    INCF		0X20,F
	    
	    MOVLW		.16
	    XORWF		0X20,W
	    BTFSS		STATUS,Z
	    GOTO		T1
	    
	    MOVLW		0X40		    ;Cambio de dirección para escribir en el segundo renglón
	    CALL		DIRECCION_DDRAM

	    MOVLW		.16
	    MOVWF		0X20
T2	    MOVF		0X20,W
	    
	    CALL		TABLA_LCD   ;Regreso con el valor en W
	    
	    CALL		CARACTER    ;Escribo el caracter
	    
	    INCF		0X20,F
	    
	    MOVLW		.32
	    XORWF		0X20,W
	    BTFSS		STATUS,Z
	    GOTO		T2	    
	    
	    CALL		LCD_ON	    ;Escribo en la LCD
	    
	    GOTO		$
	    
	    ;END al final del archivo
	    
;*********************** Subrutinas de Tiempo **********************************
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
	    
;*********************** Subrutinas de Funciones LCD ***************************	    
	    include <FuncionesLCD.inc>

	    END
