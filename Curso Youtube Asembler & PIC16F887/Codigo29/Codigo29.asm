; Consigna:
; Dibujar una carita feliz en la matriz.
; PortC = Renglones, activa los renglones con 0.
; PortB = Datos
	    LIST P=16F887
	    include <p16f887.inc>
	    include <Macros.inc>
	    
	    __config 0x2007,23E4
	    __config 0x2008,3FFF
	    
	    ORG 		0X0000
	    
	    GOTO		INICIO
;	    SIETESEGK		;Tabla para display 7 seg cátodo común
;	    SIETESEGA		;Tabla para display 7 seg ánodo común
	    
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
	    
	    CLRF		TRISB	    ;DATOS
	    CLRF		TRISC	    ;RENGLONES
	    
	    BCF			STATUS,RP0  ;Bank0
	    
	    COMF		PORTC,F
	    
REINICIO    CLRF		0X20	    ;En 0x20 voy contando hasta 8
MOSTRAR	    MOVF		0X20,W
	    CALL		ANIMA1
	    MOVWF		PORTB	    ;Sacamos el valor por el puerto de "datos"
	    
	    MOVF		0X20,W
	    CALL		RENGLONES
	    MOVWF		PORTC	    ;Prendemos el "renglon" correspondiente
	    
;   Por el efecto persistencia en la visión toda la matriz debe prenderse cada 1/60 [S] 
;   Cada fila se prende cada 1/480 [S]
	    
	    SUBT3V  		.1,.147,.2
	    
	    MOVLW		0XFF
	    MOVWF		PORTC	    ;Apago el "renglon"
	    
	    INCF		0X20,F
	    
	    MOVLW		.8
	    XORWF		0X20,W
	    BTFSS		STATUS,Z    ;Si llega a 8 se reincia
	    GOTO		MOSTRAR	    ;Repite el mismo valor 8 veces, 1/60[S]
	    GOTO		REINICIO    
	    
;   Tablas    
ANIMA1	    ADDWF		PCL,F
	    DT	.0,.36,.36,.36,.129,.66,.60,.0

	    
RENGLONES   ADDWF		PCL,F
	    DT	.254,.253,.251,.247,.239,.223,.191,.127
	    
	    
	    
	   	    
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
