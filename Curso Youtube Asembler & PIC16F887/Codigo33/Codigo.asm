; Consigna:
; Utilizando interrupciones por la terminal RB0/INT
; escribe un código que genere números pseudoaleatorios y 
; los imprima por la LCD
	    
	    LIST P=16F887
	    
	    include <p16f887.inc>
	    include <Macros.inc>
	
	    __config 0x2007,23E4
	    __config 0x2008,3FFF
	    
	    CBLOCK		0X25
				UNID,DECE,CENT
	    ENDC
	    
	    ORG 		0X0000	;Grabado a partir de la dirección 0000
	    
	    GOTO		INICIO
	    
	    ORG			0X0004  ;Grabado a partir de la dirección 0004
	    
	    include <Rescate.inc>
	    
	    GOTO		RSI	;Salto a la subrutina de Servicio de Interrupción
	    
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
	    
	    CLRF		TRISB	     ;PuertoB=Salida
	    
	    BCF			STATUS,RP0  ;Bank0
	    
	    include<Imprime32CaractLCD.inc>	    
	    
	    BSF			STATUS,RP0  ;Bank1
	    
	    COMF		TRISB,F	     ;Pongo todo como entrada PuertoB=Entrada
	    
	    BCF			STATUS,RP0  ;Bank0
	    
;   Damos los permisos de interrupción	    
	    
	    BCF			INTCON,INTF ;Bajamos la bandera antes de dar los permisos
	    BSF			INTCON,INTE ;Habilitamos las interrupciones externas
	    BSF			INTCON,GIE  ;Habilitamos las interrupciones
	    
;***********************Programa Principal*****************************    
	    
	    INCF		0X21,F	      ;Siempre esta decrementando, cuando tocan el botón deja de resta y lo guarda
	    GOTO		$-1	      ;En el momento que detecta una instrucción sale del ciclo

;*******************Rutina Servicio Interrupción***********************    
RSI	    PUSH_ANTIR		PORTB,0
	    CLRF		UNID
	    CLRF		DECE
	    CLRF		CENT
	    
;	    Pasamos de binario a decimal
RESTA100   MOVLW		.100
	    SUBWF		0X21,F
	    BTFSS		STATUS,C
	    GOTO		SUMA100
	    INCF		CENT,F
	    GOTO		RESTA100

SUMA100	    MOVLW		.100
	    ADDWF		0X21,F
	    
RESTA10	    MOVLW		.10
	    SUBWF		0X21,F
	    BTFSS		STATUS,C
	    GOTO		SUMA10
	    INCF		DECE,F
	    GOTO		RESTA10

SUMA10	    MOVLW		.10
	    ADDWF		0X21,F
	    
	    MOVF		0X21,W
	    MOVWF		UNID
	    
	    BSF			STATUS,RP0  ;Bank1
	    COMF		TRISB,F	     ;Pongo todo como entrada PuertoB=Salida
	    BCF			STATUS,RP0  ;Bank0
	    
	    MOVLW		0X30
	    ADDWF		UNID,F			;Lo pasamos a ASCII sumandole 30
	    ADDWF		DECE,F
	    ADDWF		CENT,F
	    
; Le indicamos a partir de que dirección empiezo a imprimir
	    MOVLW		0X4D
	    CALL		DIRECCION_DDRAM	
	   
	    MOVF		CENT,W
	    CALL		CARACTER		;Imprimimos centenas	    
	    MOVF		DECE,W
	    CALL		CARACTER		;Imprimimos decenas
	    MOVF		UNID,W
	    CALL		CARACTER		;Imprimimos unidades
	   
	    BSF			STATUS,RP0  ;Bank1
	    COMF		TRISB,F	     ;Pongo todo como entrada PuertoB=Entrada
	    BCF			STATUS,RP0  ;Bank0
	    
	    BCF			INTCON,INTF ;Bajamos la bandera
	    
	    include <Recuperacion.inc>    ;Contiene el RETFIE
	    
	    ;END al final del archivo
	    
;*********************** Subrutinas de Tiempo **********************************
	    include <SubrutinasTiempo.inc>    
;*********************** Subrutinas de Funciones LCD ***************************	    
	    include <FuncionesLCD.inc>

	    END
