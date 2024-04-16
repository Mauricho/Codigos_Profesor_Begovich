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
	    #DEFINE	E_1	BCF	PORTB,5	    ;E en 1
	    
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
	    
DENUEVO	    PUSH_ANTIR		PORTE,0
	    CALL		RECORRE_IZQ_LCD
	    GOTO		DENUEVO
	    
	    ;END al final del archivo
	    
;*********************** Subrutinas de Tiempo **********************************
	    include <SubrutinasTiempo.inc>    
;*********************** Subrutinas de Funciones LCD ***************************	    
	    include <FuncionesLCD.inc>

	    END
