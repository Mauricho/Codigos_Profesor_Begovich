; Consigna:
; Debe tener conectado un DIP-SW en el puerto B, cada vez que cambie de estado el DIP-SW,
; deberá interrumpir y se deberá desplegar en la LCD (Que ahora se encuentra conectada al 
; puerto C) el número de bit que cambió del puerto B.
; En el programa principal estará de forma permanente el contador de 00 a 99 por los displays
; 7 segmentos. La LCD llevará un conteo con espacios de tiempo de 2 segundos creado por Timer 0.
; las cadenas de la LCD serán:
; "Contador:       "
; "Cambió el pin:  "
	    
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
	    
	    CLRF		TRISC	     ;PuertoC=Salida
	    CLRF		TRISD
	    BCF			TRISA,0
	    BCF			TRISA,1
	    
;   Configuramos el Timer0 con Option_Reg
	    MOVLW		B'11010101' ;RB0/INT flancos de subida, TMR0 cuenta ciclos de máquina, flancos de bajada, prescaler: 1:64 
	    MOVWF		OPTION_REG
	    
	    COMF		IOCB,F	     ; Habilitamos todos los pines del puerto B como fuente de interrupción 
	    
	    BCF			STATUS,RP0  ;Bank0
	    
	    include<Imprime32CaractLCD.inc>	    
	    
	    CLRF		CONT_T0		; Limpiamos el registro
	    
; Como debemos contar 2500 eventos, dividimos en 2 y eso lo hacemos 5 veces.
; El número deseado es 250 => TMR0 = 256 - numDeseado	    
	    MOVLW		.131	      ; Timer cuenta a 125 * 64 prescaler = 8000
	    MOVWF		TMR0	      ; 256-125=131, el número que nosotros queremos es 125!
	    
	    MOVLW		.250	      ;Lo cambie para que sean 2000000 de ciclos
	    MOVWF		CONT5	      ;Contador cargado con 125
	
; Necesitamos guardar el valor de los puertos
	    MOVF		PORTB,W
	    MOVWF		ESTADO_PB   ; Estamos leyendo el puerto B
	    
;   Damos los permisos de interrupción	    	    
;   Recordar: se debe leer el puerto B antes de bajar la bandera RBIF
	    BCF			INTCON,RBIF ;Bajamos la bandera antes de dar los permisos
	    BSF			INTCON,RBIE ;Habilitamos las interrupciones por el puertoB
	    
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
	    GOTO		FUE_INT_CH    ;Solución por interrupcion en RB0
	    
	    DECFSZ		CONT5,F
	    GOTO		BAJA_BANDERA
	    
	    MOVLW		.250
	    MOVWF		CONT5
	    
	    INCF		CONT_T0	    
	    
	    MOVF		CONT_T0	,W	    
	    MOVWF		DECIMAL	    ;Pasamos ALEA a DECIMAL
	    
	    CALL		BIN_A_DEC   
	    
	    MOVLW		0X0D	    ;Donde queremos imprimir se lo pasamos al registro DIR_LCD
	    MOVWF		DIR_LCD
	    
	    CALL		IMPRIM_NUM	      
	    
;   Acomodo de nuevo la bandera
BAJA_BANDERA	    MOVLW		.131	      ; Timer cuenta a 125 * 264 prescaler = 8000
		    MOVWF		TMR0	      ; 256-250=6, el número que nosotros queremos es 250!
	    
		    BCF			INTCON,T0IF  ; Bajo la bandera de interrupción del Timer0
	    
		    GOTO		REGRESA_INT  ; Regreso de la interrupción
	    
; Lo aleatorio esta en que se mantiene el botón y la variable ale se decrementa	
; El contador ALEA es independiente de los otros contadores y me sirve para que se 
; genere un número aleatorio mientras se aprieta el botón
	    
FUE_INT_CH CALL		T25MS	    ;Elimino rebotes
	    
	    MOVLW		0X4F	    ;Donde queremos imprimir se lo pasamos al registro DIR_LCD
	    MOVWF		DIR_LCD
	    
	    CALL		DIRECCION_DDRAM
		    
BUSCA_BIT  MOVF		PORTB,W
	    
	    XORWF		ESTADO_PB,W ;Hago XOR para saber que bit me quedo
	    
	    MOVWF		EST_NU_PB   ;Lo utilizo para hacer el caso prohibido
	    
	    MOVLW		.8	     ;Estado prohibido
	    
; Pregunto por cada bit del puerto B	    
	    
	    BTFSC		EST_NU_PB,0
	    MOVLW		.0 
	    BTFSC		EST_NU_PB,1
	    MOVLW		.1
	    BTFSC		EST_NU_PB,2
	    MOVLW		.2
	    BTFSC		EST_NU_PB,3
	    MOVLW		.3
	    BTFSC		EST_NU_PB,4
	    MOVLW		.4
	    BTFSC		EST_NU_PB,5
	    MOVLW		.5
	    BTFSC		EST_NU_PB,6
	    MOVLW		.6
	    BTFSC		EST_NU_PB,7
	    MOVLW		.7
	    
	    MOVWF		EST_NU_PB
	    XORLW		.8
	    BTFSC		STATUS,Z
	    GOTO		BUSCA_BIT	; Obligo a que busque entre los bits que tenemos
	    
	    MOVF		EST_NU_PB,W	; Pasamos lo que encontramos a W
	    ADDLW		0X30		; Lo pasamos a ACII
	    CALL		CARACTER
	    
	     MOVF		PORTB,W
	    MOVWF		ESTADO_PB   ; Estamos leyendo el puerto B	    
;   Damos los permisos de interrupción	    	    
;   Recordar: se debe leer el puerto B antes de bajar la bandera RBIF
	    BCF			INTCON,RBIF ;Bajamos la bandera antes de dar los permisos
	    
REGRESA_INT	
	    NOP		;Este nop en porque no permite tener la etiqueta pegada al include
	    include <Recuperacion.inc>    ;Contiene el RETFIE
	    
	    ;END al final del archivo

;**************** Subrutinas de Binario a Decimal *********************
BIN_A_DEC  CLRF		UNID_L
	    CLRF		DECE_L
	    CLRF		CENT_L
	    
; Pasamos de binario a decimal
RESTA100   MOVLW		.100
	    SUBWF		DECIMAL,F
	    BTFSS		STATUS,C
	    GOTO		SUMA100
	    INCF		CENT_L,F
	    GOTO		RESTA100

SUMA100	    MOVLW		.100
	    ADDWF		DECIMAL,F
	    
RESTA10	    MOVLW		.10
	    SUBWF		DECIMAL,F
	    BTFSS		STATUS,C
	    GOTO		SUMA10
	    INCF		DECE_L,F
	    GOTO		RESTA10

SUMA10	    MOVLW		.10
	    ADDWF		DECIMAL,F
	    
	    MOVF		DECIMAL,W
	    MOVWF		UNID_L
	    
	    RETURN 
	    
;******* Subrutina para imprimir, primero sumamos 30 para pasarlo ASCII ********
IMPRIM_NUM	MOVLW		0X30
		ADDWF		UNID_L,F    ;Lo pasamos a ASCII sumandole 30
		ADDWF		DECE_L,F
		ADDWF		CENT_L,F
	    
; Le indicamos a partir de que dirección empiezo a imprimir
		MOVF		DIR_LCD,W    
		CALL		DIRECCION_DDRAM	

		MOVF		CENT_L,W
		CALL		CARACTER		;Imprimimos centenas	    
		MOVF		DECE_L,W
		CALL		CARACTER		;Imprimimos decenas
		MOVF		UNID_L,W
		CALL		CARACTER		;Imprimimos unidades

		RETURN
	    	    
;*********************** Subrutinas de Tiempo *************************
	    include <SubrutinasTiempo.inc>    
;*********************** Subrutinas de Funciones LCD ******************	    
	    include <FuncionesLCD.inc>
	    
	    END