; Consigna:
; Usando el Timer0 como fuente de interrupción, debe contar eventos por
; la terminal RA4, al llegar a 2500 debe emitir un tono de 1[kHz] por 
; RC2 durante 500 [mS].
; En el programa principal estará de forma permanente el contador de 00
; a 99 por los displays de 7 segmentos. Pero esta secuencia también 
; puede ser interrumpida por RB0/INT, al entrar a la interrupción gene-
; rará el número aleatorio y lo imprimira en la LCD.
 
	    LIST P=16F887
	    
	    include <p16f887.inc>
	    include <Macros.inc>
	    include <Definiciones.inc>
	    
	    __config 0x2007,23E4
	    __config 0x2008,3FFF
	    
	    ORG 		0X0000	;Grabado a partir de la dirección 0000
	    
	    GOTO		INICIO
	    
	    ORG			0X0004  ;Grabado a partir de la dirección 0004
	    
	    include <Rescate.inc>
	    
	    GOTO		RSI	;Salto a la subrutina de Servicio de Interrupción
	    
	    SIETESEGK		;Tabla para display 7 seg cátodo común
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
	    
	    CLRF		TRISB	     ;PuertoB=Salida
	    CLRF		TRISD
	    BCF			TRISA,0
	    BCF			TRISA,1
	    BCF			TRISC,2
	    
	    BCF			STATUS,RP0  ;Bank0
	    
	    include<Imprime32CaractLCD.inc>	    
	    
	    BSF			STATUS,RP0  ;Bank1
	    
; Hacemos esto porque utilizamos un interruptor en RB0
	    COMF		TRISB,F	     ;Pongo todo como entrada PuertoB=Entrada
	    
;   Configuramos el Timer0 con Option_Reg
	    MOVLW		B'11110000' ;RB0/INT flancos de subida, TMR0 por RA4, flancos de bajada, prescaler: 1:2 
	    MOVWF		OPTION_REG
	    
	    BCF			STATUS,RP0  ;Bank0
	    
; Como debemos contar 2500 eventos, dividimos en 2 y eso lo hacemos 5 veces.
; El número deseado es 250 => TMR0 = 256 - numDeseado	    
	    MOVLW		.6	      ; Timer cuenta a 250 * 2 prescaler = 500
	    MOVWF		TMR0	      ; 256-250=6, el número que nosotros queremos es 250!
	    
	    MOVLW		.5
	    MOVWF		CONT5	      ;Contador cargado con 5
	    
;   Damos los permisos de interrupción	    	    
	    BCF			INTCON,INTF ;Bajamos la bandera antes de dar los permisos
	    BSF			INTCON,INTE ;Habilitamos las interrupciones externas
	    
	    BCF			INTCON,T0IF ;Bajamos la bandera de TMR0 antes de dar los permisos
	    BSF			INTCON,T0IE ;Habilitamos las interrupciones por TMR0
	    
	    BSF			INTCON,GIE  ;Habilitamos las interrupciones globales
	    
;***********************Programa Principal*****************************    
;Programa principal contador de 00 a 99, display 7 segmentos
LIMPIADEC   CLRF		DECE
LIMPIAUNI   CLRF		UNID
	    
RECARGA60  MOVLW		.60
	    MOVWF		CONT60		
	    
REP	    MOVF		UNID,W
	    CALL		SIETESEG
	    MOVWF		PORTD	    ;Muestro el valor
	    UNID_E
	    CALL		T120AVO
	    UNID_A
	    
	    MOVF		DECE,W
	    CALL		SIETESEG
	    MOVWF		PORTD	    ;Muestro el valor
	    DECE_E			    ;---
	    CALL		T120AVO
	    DECE_A
						
	    DECFSZ		CONT60,F   ;---
	    GOTO		REP	    ;Repito durante 1 seg
	    
	    INCF		UNID,F
	    MOVLW		0X0A
	    XORWF		UNID,W  ;Incrementa unidades y lo compara
	    
	    BTFSS		STATUS,Z    ;Si llega a 10 incrementa decena
	    GOTO		RECARGA60   ;caso contrario vuelve a empezar
	    
	    INCF		DECE,F
	    MOVLW		0X0A
	    XORWF		DECE,W   ;Incrementa decenas y lo compara
	    
	    BTFSS		STATUS,Z    ;Si llega a 10 vuelve a empezar
	    GOTO		LIMPIAUNI   ;caso contrario vuelve a empezar
	    
	    GOTO		LIMPIADEC
	    
;*******************Rutina Servicio Interrupción***********************    
RSI	    BTFSS		INTCON,T0IF
	    GOTO		FUE_RB0	    ;Solución por interrupcion en RB0
	    
	    DECFSZ		CONT5,F
	    GOTO		BAJA_BANDERA
	    
	    MOVLW		.5
	    MOVWF		CONT5
	    
	    MOVLW		.2	   ;Como tengo que contar hasta 500, hago 2 variables una de 2 y otra de 250 
	    MOVWF		0X28
REC_TONO   MOVLW		.250
	    MOVWF		0X29
	    
TONO	    BSF			PORTC,2
	    CALL		T500US
	    BCF			PORTC,2
	    CALL		T500US
	    
	    DECFSZ		0X29,F
	    GOTO		TONO
	    
	    DECFSZ		0X28,F
	    GOTO		REC_TONO    
	    
	    
BAJA_BANDERA	    MOVLW		.6	      ; Timer cuenta a 250 * 2 prescaler = 500
		    MOVWF		TMR0	      ; 256-250=6, el número que nosotros queremos es 250!
	    
		    BCF			INTCON,T0IF ;Bajo la bandera de interrupción
	    
		    GOTO		REGRESA_INT

;   Subrutina de tiempo de 500[uS]
T500US	    SUBT3V	.1,.69,.1
	    RETURN
	    
; Lo aleatorio esta en que se mantiene el botón y la variable ale se decrementa	    
FUE_RB0	    CALL		T25MS	    ;Elimino rebotes
	    INCF		ALEA,F	    ;Incremento alea
	    BTFSC		PORTB,0	    ;Si no se solto sigo incrementando alea
	    GOTO		$-2
	    CALL		T25MS	    ;Elimino rebotes
	    
	    CLRF		UNID_L
	    CLRF		DECE_L
	    CLRF		CENT_L
	    
;	    Pasamos de binario a decimal
RESTA100   MOVLW		.100
	    SUBWF		ALEA,F
	    BTFSS		STATUS,C
	    GOTO		SUMA100
	    INCF		CENT_L,F
	    GOTO		RESTA100

SUMA100	    MOVLW		.100
	    ADDWF		ALEA,F
	    
RESTA10	    MOVLW		.10
	    SUBWF		ALEA,F
	    BTFSS		STATUS,C
	    GOTO		SUMA10
	    INCF		DECE_L,F
	    GOTO		RESTA10

SUMA10	    MOVLW		.10
	    ADDWF		ALEA,F
	    
	    MOVF		ALEA,W
	    MOVWF		UNID_L
	    
	    BSF			STATUS,RP0  ;Bank1
	    COMF		TRISB,F	     ;Pongo todo como entrada PuertoB=Salida
	    BCF			STATUS,RP0  ;Bank0
	    
	    MOVLW		0X30
	    ADDWF		UNID_L,F    ;Lo pasamos a ASCII sumandole 30
	    ADDWF		DECE_L,F
	    ADDWF		CENT_L,F
	    
; Le indicamos a partir de que dirección empiezo a imprimir
	    MOVLW		0X4D
	    CALL		DIRECCION_DDRAM	
	   
	    MOVF		CENT_L,W
	    CALL		CARACTER		;Imprimimos centenas	    
	    MOVF		DECE_L,W
	    CALL		CARACTER		;Imprimimos decenas
	    MOVF		UNID_L,W
	    CALL		CARACTER		;Imprimimos unidades
	   
	    BSF			STATUS,RP0  ;Bank1
	    COMF		TRISB,F	     ;Pongo todo como entrada PuertoB=Entrada
	    BCF			STATUS,RP0  ;Bank0
	    
	    BCF			INTCON,INTF ;Bajamos la bandera
	    
REGRESA_INT	
	    NOP  
	    include <Recuperacion.inc>    ;Contiene el RETFIE
	    
	    ;END al final del archivo
	    
;*********************** Subrutinas de Tiempo **********************************
	    include <SubrutinasTiempo.inc>    
;*********************** Subrutinas de Funciones LCD ***************************	    
	    include <FuncionesLCD.inc>

	    END
