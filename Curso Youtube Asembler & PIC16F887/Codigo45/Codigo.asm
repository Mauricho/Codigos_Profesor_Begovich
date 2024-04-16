; Consigna:
; Debe tener conectado un teclado matricial de 4x4 en el puerto B, cuando se apriete cualquier
; tecla deber� interrumpir y transmitir por UART a 9600 Baudios el n�mero de tecla que se apret�.
; Al recibir un dato por UART deber� interrumpir (apagar los displays de 7 seg) y mostrar el dato 
; por la pantalla del celular, ya que se esta usando el modulo bluetooth.	    
; En el programa principal estar� de forma permanente el contador de 00 a 99 por los displays de
; 7 segmentos.	    
; Ahora RE0 y RE1 controlan los transistores de los displays.
; Me permite la conexi�n bluetooth con el dispositivo	    
	    
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
;	    LCD_MACRO		;Tabla para LCD
	    TABLATECL		;Tabla para el teclado matricial 4x4 
;	    TABLA_H_A		;Tabla Hexa a ASCII para el teclado 
;	    TABLAPWM
	    
INICIO	    CLRF 		PORTA
	    CLRF 		PORTB
	    CLRF		PORTC
	    CLRF 		PORTD
	    CLRF		PORTE
	
	    BSF			STATUS,RP0
	    BSF			STATUS,RP1  ;Bank3
	    
	    CLRF    		ANSEL
	    CLRF		ANSELH
	
	    BCF			STATUS,RP1  ;Bank1
;************* Configuro Transmisi�n: *******************************
	    MOVLW		.25		;Tasa de Transferencia a 9600[Baudios]
	    MOVWF		SPBRG		;BRG16=0 por defecto, y SPBRGH no se requiere
	    
	    MOVLW		0X26		;Ver cada bit para entenderlo mejor     
	    MOVWF		TXSTA		;UART 8 bits,TX=enc,asincrono,BRGH=1 
;********************************************************************
	    
	    MOVLW		0XF0
	    MOVWF		TRISB	     ;"Debo modificar antes al TRISB que las resistencia de elevaci�n" 
	    CLRF		TRISD	     ; Datos display 7 segmento
	    CLRF		PORTA		;Salida para la barra de led
	    BCF			TRISE,0		;Son los pines que controlan los displays
	    BCF			TRISE,1
	    
;   Configuramos el Timer0 con Option_Reg
	    BCF			OPTION_REG,7;Activo RBPU,			    
	    COMF		IOCB,F	     ; Habilitamos todos los pines del puerto B como fuente de interrupci�n 
	    
	    BCF			STATUS,RP0  ;Bank0  
	    
;****************** Configuro Recepci�n ********************************	  
	    MOVLW		0X90
	    MOVWF		RCSTA	    ;UART encendido, 8 bits, RX=encendido
;**********************************************************************	    
	    
; Doy permisos de interrupci�n a la Recepci�n
	    BCF			PIR1,RCIF	;Bajo bandera 
	    
	    BSF			STATUS,RP0	;Banco 1
	    
	    BSF			PIE1,RCIE	;Habilito interrupci�n: UASRT recepcion
	    
	    BCF			STATUS,RP0	;Banco 0
	    
; Necesitamos guardar el valor de los puertos
	    MOVF		PORTB,W
	    
;   Damos los permisos de interrupci�n para el teclado    	    
;   Recordar: se debe leer el puerto B antes de bajar la bandera RBIF
	    BCF			INTCON,RBIF ;Bajamos la bandera antes de dar los permisos
	    BSF			INTCON,RBIE ;Habilitamos las interrupciones por el puertoB
	    BSF			INTCON,PEIE ;Damos el permiso de interrupcion a perifericos
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
RSI	    BTFSS		INTCON, RBIF	    ;Fue el teclado?
	    GOTO		FUE_UART_RX
	    
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
	    GOTO		TX_UART
	    INCF		CONT_TECL,F
	    MOVLW		.16		;Se va a repetir de acuerdo a la cantidad de teclas
	    
	    XORWF		CONT_TECL,W  
	    BTFSS		STATUS,Z
	    GOTO		BUSCA_TECLA	;Cuando contador sea igual a 16 
	    MOVLW		.16		;Se carga con 16 si no identifica a ninguna
	    MOVWF		CONT_TECL	;Aqu� se guarda el n�mero de tecla identificada
	    
;********************* Transmisi�n	***********************************  
TX_UART    CALL		TX_LIBRE
	    MOVLW		'H'		  ;Cargo un valor para transmitir
	    MOVWF		TXREG
	    
	    CALL		TX_LIBRE
	    MOVLW		'o'		  ;Cargo un valor para transmitir
	    MOVWF		TXREG
	    
	    CALL		TX_LIBRE
	    MOVLW		'l'		  ;Cargo un valor para transmitir
	    MOVWF		TXREG
	    
	    CALL		TX_LIBRE
	    MOVLW		'a'		  ;Cargo un valor para transmitir
	    MOVWF		TXREG
	    
	    CALL		TX_LIBRE
	    MOVLW		' '		  ;Cargo un valor para transmitir, en este caso el espacio
	    MOVWF		TXREG
	    
	    INCF		CONT_TECL,W	; Le sumamos 1 para que la tecla 0 valga 1 y as� hasta 16, y lo pasamos a W
	    ADDLW               0X30		 ;Lo env�a en ASCII   
	    MOVWF		TXREG		;Escribimos para que se transmitan los datos 
	    
	    CALL		TX_LIBRE
	    MOVLW		.10		  ;Cargo un valor para transmitir, en este caso es el salto de l�nea
	    MOVWF		TXREG
	    
	    CALL		TX_LIBRE
	    MOVLW		.13		  ;Cargo un valor para transmitir, en este caso es el retorno de carro (volver al principio de l�nea)
	    MOVWF		TXREG
	    
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
	    
	    GOTO		REGRESA_INT
;********************** Recepci�n *******************************************
FUE_UART_RX 
; Me fijo si hubo alg�n error
	    BTFSC		RCSTA,FERR
	    GOTO		RX_ERROR
	    BTFSC		RCSTA,OERR
    	    GOTO		RX_ERROR
	    
;Algoritmo para convertir los n�meros que se pulsan en el teclado 4x4 a ASCII   
	    MOVF		RCREG,W
	    
	    MOVWF		0X30		;Enviamos el dato recibido a un registro de la RAM
	    MOVLW		0X60
	    SUBWF		0X30,F
	    
	    SWAPF		0X30,W
	    ANDLW		0XF0		;Eliminamos la parte baja
;**********************************************************************	    
	    MOVWF		PORTA
	    GOTO		BAJA_RCIF
	    
RX_ERROR   BCF			RCSTA,CREN  ;Habilito y deshabilito el bit CREN para poder bajar la bandera
	    BSF			RCSTA,CREN
	    
	    MOVF		RCREG,W
	    MOVF		RCREG,W
	    
BAJA_RCIF  BCF			PIR1,RCIF
	    
;**********************************************************************	    
REGRESA_INT	
	    NOP		;Este nop es porque no permite tener la etiqueta pegada al include
	    include <Recuperacion.inc>    ;Contiene el RETFIE
	    

	    ;END al final del archivo
	    	    
;*********************** Subrutinas de Tiempo *************************
	    include <SubrutinasTiempo.inc>    
;*********************** Subrutinas de Funciones LCD ******************	    
	    include <FuncionesLCD.inc>
;********************** Subrutina que pregunta si puedo transmitir ****
TX_LIBRE   BSF			STATUS,RP0	;Banco 1
	    
	    BTFSS		TXSTA,TRMT	;Antes de transmitir pregunto si es que puedo.
	    GOTO		    $-1		;Pregunto hasta que pueda transmitir
	    
	    BCF			STATUS,RP0	;Banco 0
	    RETURN
	    
	    END
