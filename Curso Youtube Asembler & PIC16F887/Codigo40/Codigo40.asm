; Consigna:
; Debe tener conectado un teclado matricial de 4x4 en el puerto B, cuando se apriete cualquier
; tecla deber� interrumpir y desplegar en la LCD (conectada al puerto C) 
; el n�mero de la tecla que se est� apretando (en hexadecimal)
;	    
; En el programa principal estar� de forma permanente el contador de 00 a 99
; por los displays de 7 segmentos.
; 
; La LCD llevar� un conteo con espacios de tiempo de 0.5 segundos creado por Timer0.
; Tambi�n, cada 0.5 segundos adentro de la interrupci�n del Timer0 se har� una conversi�n AD y
; se imprimir� el resultado de CAD (Conversi�n Anal�gica Digital)	    
; Vres = 2.558 [V]. El pin anal�gico a utilizar como entrada ser� RE0/AN5.
; Reloj del ADC = RC interno
;	    
; Deber� desplegar la temperatura utilizando el sensor LM35 con una resoluci�n de 0,25 �C,
; la entrada del sensor ser� RE2/AN7
; 
; Las cadenas de la LCD ser�n:
; "XXX Vi:xxxx.x mV"
; "Tec:  T=XXX.XXC�"
	    
	    LIST P=16F887
	    
	    include <p16f887.inc>
	    include <Macros.inc>
	    include <Definiciones.inc>
	    
	    __config 0x2007,23E4
	    __config 0x2008,3FFF
	    
	    ORG 		0X0000	;Grabado a partir de la direcci�n 0000
	    
	    GOTO		INICIO
	    
	    ORG			0X0004  ;Grabado a partir de la direcci�n 0004
	    
	    include <Rescate.inc>
	    
	    GOTO		RSI	;Salto a la subrutina de Servicio de Interrupci�n
	    
	    SIETESEGK		;Tabla para display 7 seg c�todo com�n
;	    SIETESEGA		;Tabla para display 7 seg �nodo com�n
	    LCD_MACRO		;Tabla para LCD
	    TABLATECL		;Tabla para el teclado matricial 4x4 
	    TABLA_H_A		;Tabla Hexa a ASCII para el teclado 
	    
INICIO	    CLRF 		PORTA
	    CLRF 		PORTB
	    CLRF		PORTC
	    CLRF 		PORTD
	    CLRF		PORTE
	
	    BSF			STATUS,RP0
	    BSF			STATUS,RP1  ;Bank3
	    
	    MOVLW		B'10101000' ;Entrada anal�gica por AN7, AN5 y VREF+ por AN3
	    MOVWF 		ANSEL
	    CLRF		ANSELH
	
	    BCF			STATUS,RP1  ;Bank1
	    
	    MOVLW		0XF0
	    MOVWF		TRISB	     ;"Debo modificar antes al TRISB que las resistencia de elevaci�n" 
	    
	    CLRF		TRISC	     ;PuertoC=Salida
	    CLRF		TRISD
	    BCF			TRISA,0
	    BCF			TRISA,1
	    
;   Configuramos el Timer0 con Option_Reg
	    MOVLW		B'01010101' ;Activo RBPU, RB0/INT flancos de subida, TMR0 cuenta ciclos de m�quina, flancos de bajada, prescaler: 1:64 
	    MOVWF		OPTION_REG
	    
	    COMF		IOCB,F	     ; Habilitamos todos los pines del puerto B como fuente de interrupci�n 
	    
	    MOVLW		B'00010000' ;Ajuste a la izq., Vref-=Vss, Vref+=An3
	    MOVWF		ADCON1
	    
	    BCF			STATUS,RP0  ;Bank0
	    
	    include<Imprime32CaractLCD.inc>	    
	    
	    CLRF		CONT_T0		; Limpiamos el registro
	    
; Como debemos contar 2500 eventos, dividimos en 2 y eso lo hacemos 5 veces.
; El n�mero deseado es 250 => TMR0 = 256 - numDeseado	    
	    MOVLW		.131	      ; Timer cuenta a 125 * 64 prescaler = 8000
	    MOVWF		TMR0	      ; 256-125=131, el n�mero que nosotros queremos es 125!
	    
	    MOVLW		.62	      ;Lo cambie para que sean 500000 de ciclos
	    MOVWF		CONT5	      ;Contador cargado con 125
	    
	    MOVLW		B'11010101'  ; Reloj ADC = RC interno, canal anal�gico = AN5(Fuente de tensi�n), no inicia, AD encendido
	    MOVWF		ADCON0
; Si desea interrupci�n por Conversi�n Analogica-Digital, baja a ADIF y habilita a ADIE,PEIE,GIE
	    
; Necesitamos guardar el valor de los puertos
	    MOVF		PORTB,W
	    
;   Damos los permisos de interrupci�n	    	    
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
	    
;*******************Rutina Servicio Interrupci�n***********************    
RSI	    BTFSS		INTCON,T0IF
	    GOTO		FUE_INT_CH    ;Soluci�n por interrupcion en RB0
	    
	    DECFSZ		CONT5,F
	    GOTO		BAJA_BANDERA
	    
	    BSF			ADCON0,1	;Inicia la Conversi�n Anal�gica Digital
	    
	    MOVLW		.62
	    MOVWF		CONT5
	    
	    INCF		CONT_T0	    
	    
	    MOVF		CONT_T0	,W	    
	    MOVWF		DECIMAL	    ;Pasamos ALEA a DECIMAL
	    
	    CALL		BIN_A_DEC   
	    
	    MOVLW		0X00	    ;Donde queremos imprimir se lo pasamos al registro DIR_LCD
	    MOVWF		DIR_LCD
	    
	    CALL		IMPRIM_NUM	      
	    
	    BTFSC		ADCON0,1	;Ya termino la Conversi�n Anal�gica Digital?
	    GOTO		$-1
	    
	    MOVLW		B'11011101'  ; Cambio de canal anal�gico Reloj ADC = RC interno, canal anal�gico = AN7(LM35), no inicia, AD encendido
	    MOVWF		ADCON0
	    
	    MOVF		ADRESH,W    ;El resultado del ADC lo paso a W 
	    MOVWF		DECIMAL	    ;Paso de binario a decimal
	    CALL		BIN_A_DEC 
	    
	    MOVLW		0X07	    ;Donde queremos imprimir se lo pasamos al registro DIR_LCD
	    MOVWF		DIR_LCD
	    
	    CALL		IMPRIM_NUM ;Imprime la parte alta del resultado de la Conversi�n A-D
	    
	    BSF			STATUS,RP0  ; Bank1
	    
	    MOVF		ADRESL,W    ;Guardamos la parte baja del resultado en W
	    
	    BCF			STATUS,RP0  ; Bank 0
	    
	    MOVWF		ADL
	    CLRW			      ;Caso ADRESL = 00
	    XORWF		ADL,W
	    BTFSS		STATUS,Z
	    
	    GOTO		FUE01		
	    
	    MOVLW		'0'
	    CALL		CARACTER
	    MOVLW		'.'
	    CALL		CARACTER
	    MOVLW		'0'
	    CALL		CARACTER
	    
	    GOTO		IMP_TEMP
	    
FUE01	    MOVLW		B'01000000' ;Caso ADRESL = 01
	    XORWF		ADL,W
	    BTFSS		STATUS,Z
	    
	    GOTO		FUE10
	    
	    MOVLW		'2'
	    CALL		CARACTER
	    MOVLW		'.'
	    CALL		CARACTER
	    MOVLW		'5'
	    CALL		CARACTER
	    
	    GOTO		IMP_TEMP
	    
FUE10	    MOVLW		B'10000000' ;Caso ADRESL = 10
	    XORWF		ADL,W
	    BTFSS		STATUS,Z
	    
	    GOTO		FUE11
	    
	    MOVLW		'5'
	    CALL		CARACTER
	    MOVLW		'.'
	    CALL		CARACTER
	    MOVLW		'0'
	    CALL		CARACTER
	    
	    GOTO		IMP_TEMP
	    
FUE11	    MOVLW		'7'	      ;Caso ADRESL = 11
	    CALL		CARACTER
	    MOVLW		'.'
	    CALL		CARACTER
	    MOVLW		'5'
	    CALL		CARACTER
	    
IMP_TEMP   BSF			ADCON0,1	;Inicia la Conversi�n Anal�gica Digital
	    
	    BTFSC		ADCON0,1	;Ya termino la Conversi�n Anal�gica Digital?
	    GOTO		$-1
	    
; Regresamos al canal 5 que es la fuente de tensi�n
	    MOVLW		B'11010101'  ; Reloj ADC = RC interno, canal anal�gico = AN5(Fuente de tensi�n), no inicia, AD encendido
	    MOVWF		ADCON0
	    
	    MOVF		ADRESH,W    ;El resultado del ADC lo paso a W 
	    MOVWF		DECIMAL	    ;Paso de binario a decimal
	    CALL		BIN_A_DEC 
	    
	    MOVLW		0X48	    ;Donde queremos imprimir se lo pasamos al registro DIR_LCD
	    MOVWF		DIR_LCD
	    
	    CALL		IMPRIM_NUM ;Imprime la parte alta del resultado de la Conversi�n A-D
	    
	    BSF			STATUS,RP0  ; Bank1
	    
	    MOVF		ADRESL,W    ;Guardamos la parte baja del resultado en W
	    
	    BCF			STATUS,RP0  ; Bank 0
	    
	    MOVWF		ADL
	    CLRW			      ;Caso ADRESL = 00
	    XORWF		ADL,W
	    BTFSS		STATUS,Z
	    
	    GOTO		LM35FUE01		
	    
	    MOVLW		'.'
	    CALL		CARACTER
	    MOVLW		'0'
	    CALL		CARACTER
	    MOVLW		'0'
	    CALL		CARACTER
	    
	    GOTO		BAJA_BANDERA
	    
LM35FUE01	   
	    MOVLW		B'01000000' ;Caso ADRESL = 01
	    XORWF		ADL,W
	    BTFSS		STATUS,Z
	    
	    GOTO		LM35FUE10
	    
	    MOVLW		'.'
	    CALL		CARACTER
	    MOVLW		'2'
	    CALL		CARACTER
	    MOVLW		'5'
	    CALL		CARACTER
	    
	    GOTO		BAJA_BANDERA
	    
LM35FUE10
	    MOVLW		B'10000000' ;Caso ADRESL = 10
	    XORWF		ADL,W
	    BTFSS		STATUS,Z
	    
	    GOTO		LM35FUE11
	    
	    MOVLW		'.'
	    CALL		CARACTER
	    MOVLW		'5'
	    CALL		CARACTER
	    MOVLW		'0'
	    CALL		CARACTER
	    
	    GOTO		BAJA_BANDERA
	    
LM35FUE11	    
	    MOVLW		'.'	      ;Caso ADRESL = 11
	    CALL		CARACTER
	    MOVLW		'7'
	    CALL		CARACTER
	    MOVLW		'5'
	    CALL		CARACTER
	    
;   Acomodo de nuevo la bandera
BAJA_BANDERA	    MOVLW		.131	      ; Timer cuenta a 125 * 264 prescaler = 8000
		    MOVWF		TMR0	      ; 256-250=6, el n�mero que nosotros queremos es 250!
	    
		    BCF			INTCON,T0IF  ; Bajo la bandera de interrupci�n del Timer0
	    
		    GOTO		REGRESA_INT  ; Regreso de la interrupci�n
	    
; Lo aleatorio esta en que se mantiene el bot�n y la variable ale se decrementa	
; El contador ALEA es independiente de los otros contadores y me sirve para que se 
; genere un n�mero aleatorio mientras se aprieta el bot�n
	    
FUE_INT_CH CLRF		TRISA	    ;Se apagan los displays
		    
	    CALL		T25MS	    ;Elimino rebotes
	    
	    MOVLW		0XF0
	    ANDWF		PORTB,W
	    MOVWF		TECLADO4X4
	    
	    BSF			STATUS,RP0  ;Banco1
	    
	    MOVLW		0X0F
	    
	    MOVWF		TRISB
	    BCF			OPTION_REG,7 ;Activo las resistencia de elevaci�n
	    
	    BCF			STATUS,RP0   ;Banco0
	    
	    CLRF		PORTB
	    
	    MOVLW		0X0F		
	    ANDWF		PORTB,W
	    
	    ADDWF		TECLADO4X4,F ;Valores concatenados para buscar en la tabla
	    
	    CLRF		CONT_TECL	;Contador que me permite recorrer la tabla y preguntar para cada caso
	    
BUSCA_TECLA 
	    MOVF		CONT_TECL,W
	    CALL		TABLA_TECL
	    XORWF		TECLADO4X4,W	;Pregunto por cada valor de la tabla para ver si es el que se apreto en el teclado
	    
	    BTFSC		STATUS,Z  ;Lo hacemos para que recorra todas las teclas y encuentre alg�n resultado
	    GOTO		DIRECC_IMPR
	    INCF		CONT_TECL,F
	    MOVLW		.16		;Se va a repetir de acuerdo a la cantidad de teclas
	    
	    XORWF		CONT_TECL,W  
	    BTFSS		STATUS,Z
	    GOTO		BUSCA_TECLA	;Cuando contador sea igual a 16 
	    MOVLW		.16
	    MOVWF		CONT_TECL
	    
DIRECC_IMPR	   
	    MOVLW		0X44	    ;Donde queremos imprimir se lo pasamos al registro DIR_LCD
	    MOVWF		DIR_LCD
	    CALL		DIRECCION_DDRAM
	    
	    MOVF		CONT_TECL,W	; Pasamos lo que encontramos a W 
	    CALL		TABLA_HEX_ASCII
	    CALL		CARACTER
	    
	    MOVLW		0X0F
	    XORWF		PORTB,W
	    BTFSS		STATUS,Z
	    GOTO		$-3	    ;De esta forma evito que entre permanentemente al caso prohibido de forma permanente
					    ;NO queda permanentemente interrumpido
					    
	    CALL		T25MS	    ;Elimino rebotes
	    
	    BSF			STATUS,RP0  ;Banco1
	    
	    MOVLW		0XF0
	    
	    MOVWF		TRISB
	    BCF			OPTION_REG,7 ;Activo las resistencia de elevaci�n
	    
	    BCF			STATUS,RP0   ;Banco0
	    
	    MOVF		PORTB,W    
	    BCF			INTCON,RBIF ;Bajamos la bandera antes de dar los permisos
	    
REGRESA_INT	
	    NOP		;Este nop es porque no permite tener la etiqueta pegada al include
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
	    
; Le indicamos a partir de que direcci�n empiezo a imprimir
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