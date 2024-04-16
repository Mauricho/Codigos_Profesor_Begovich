; Consigna:
; Usando el Timer0 como fuente de interrupci�n, debe contar ciclos de 
; m�quina y cada vez que cuente 1000000 ciclos debe imprimir en los 3
; �ltimos espacios del rengl�n 1 de la LCD el incremento de un contador
; En el programa principal estar� de forma permanente el contador de 00
; a 99 por los displays de 7 segmentos. Pero esta secuencia tambi�n 
; puede ser interrumpida por RB0/INT, al entrar a la interrupci�n 
; generar� el n�mero aleatorio y lo imprimira en la LCD.
	    
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
	    MOVLW		B'11010101' ;RB0/INT flancos de subida, TMR0 cuenta ciclos de m�quina, flancos de bajada, prescaler: 1:64 
	    MOVWF		OPTION_REG
	    
	    BCF			STATUS,RP0  ;Bank0
	    
	    CLRF		CONT_T0		; Limpiamos el registro
	    
; Como debemos contar 2500 eventos, dividimos en 2 y eso lo hacemos 5 veces.
; El n�mero deseado es 250 => TMR0 = 256 - numDeseado	    
	    MOVLW		.131	      ; Timer cuenta a 125 * 64 prescaler = 8000
	    MOVWF		TMR0	      ; 256-125=131, el n�mero que nosotros queremos es 125!
	    
	    MOVLW		.125
	    MOVWF		CONT5	      ;Contador cargado con 125
	    
;   Damos los permisos de interrupci�n	    	    
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
	    
;*******************Rutina Servicio Interrupci�n***********************    
RSI	    BTFSS		INTCON,T0IF
	    GOTO		FUE_RB0	    ;Soluci�n por interrupcion en RB0
	    
	    DECFSZ		CONT5,F
	    GOTO		BAJA_BANDERA
	    
	    MOVLW		.125
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
		    MOVWF		TMR0	      ; 256-250=6, el n�mero que nosotros queremos es 250!
	    
		    BCF			INTCON,T0IF  ; Bajo la bandera de interrupci�n del Timer0
		    BCF			INTCON,INTF  ;	Bajo la bandera de interrupci�n, se puede haber levantado por error
	    
		    GOTO		REGRESA_INT  ; Regreso de la interrupci�n
	    
; Lo aleatorio esta en que se mantiene el bot�n y la variable ale se decrementa	
; El contador ALEA es independiente de los otros contadores y me sirve para que se 
; genere un n�mero aleatorio mientras se aprieta el bot�n
	    
FUE_RB0	    CLRF		PORTA	    ;Apago los displays al entrar a la interrupci�n, pero en realidad 
					    ;lo hago cuando se aprieta el bot�n. Porque entra muchas veces a la 
					    ;interrupci�n y los displays parpadean
	    CALL		T25MS	    ;Elimino rebotes
	    INCF		ALEA,F	    ;Incremento alea
	    BTFSC		PORTB,0	    ;Si no se solto sigo incrementando alea
	    GOTO		$-2
	    CALL		T25MS	    ;Elimino rebotes
	    
	    MOVF		ALEA,W	    
	    MOVWF		DECIMAL	    ;Pasamos ALEA a DECIMAL
	    
	    CALL		BIN_A_DEC   
	    
	    MOVLW		0X4D	    ;Donde queremos imprimir se lo pasamos al registro DIR_LCD
	    MOVWF		DIR_LCD
	    
	    CALL		IMPRIM_NUM
	    
	    BCF			INTCON,INTF ;Bajamos la bandera
	    
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
	    
		BSF		STATUS,RP0  ;Bank1
		COMF		TRISB,F	     ;Pongo todo como entrada PuertoB = Salida
		BCF		STATUS,RP0  ;Bank0
	    
; Le indicamos a partir de que direcci�n empiezo a imprimir
		MOVF		DIR_LCD,W    
		CALL		DIRECCION_DDRAM	

		MOVF		CENT_L,W
		CALL		CARACTER		;Imprimimos centenas	    
		MOVF		DECE_L,W
		CALL		CARACTER		;Imprimimos decenas
		MOVF		UNID_L,W
		CALL		CARACTER		;Imprimimos unidades

    ; Volvemos el puerto como entrada porque estamos usando el interruptor RB0 como entrada

		BSF		STATUS,RP0  ;Bank1
		COMF		TRISB,F	     ;Pongo todo como entrada PuertoB = Entrada
		BCF		STATUS,RP0  ;Bank0

		RETURN
	    	    
;*********************** Subrutinas de Tiempo *************************
	    include <SubrutinasTiempo.inc>    
;*********************** Subrutinas de Funciones LCD ******************	    
	    include <FuncionesLCD.inc>
	    
	    END