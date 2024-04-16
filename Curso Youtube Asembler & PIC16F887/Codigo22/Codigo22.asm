; Consigna:
; Escribir un código que llene de los registros 0x20 al registro 0x6F con los 
; valores 0,1,2,etc
; Luego del registro 0xA0 al registro 0xEF con la continuación de la numeración.
; Luego del registro 0x110 al registro 0x16F con la continuación de la numera-
; ción.
; Luego del registro 0x190 al registro 0x1EF con la continuación de la numera-
; ción.
	    
	    LIST P=16F887
	    include <p16f887.inc>
	    include <Macros.inc>
	    
	    __config 0x2007,23E4
	    __config 0x2008,3FFF
	    
	    NUM	    EQU		0x70
	    
	    ORG 		0X0000
	    
	    CLRF 		PORTA
	    CLRF 		PORTB
	    CLRF		PORTC
	    CLRF 		PORTD
	    CLRF		PORTE
	
	    BSF			STATUS,RP0
	    BSF			STATUS,RP1
	
	    CLRF 		ANSEL
	    CLRF		ANSELH
	
	    BCF			STATUS,RP1
	    BCF			STATUS,RP0
	    
	    MOVLW		0X00
	    MOVWF		NUM
	    
	    MOVLW		0X20
	    MOVWF		FSR
	    
REP1	    MOVF		NUM,W
	    MOVWF		INDF
	    
	    INCF		NUM,F
	    INCF		FSR,F
	    
	    MOVF		FSR,W
	    XORLW		0X70
	    
	    BTFSS		STATUS,Z
	    
	    GOTO		REP1
	    
	    MOVLW		0XA0
	    MOVWF		FSR
	    
REP2	    MOVF		NUM,W
	    MOVWF		INDF
	    
	    INCF		NUM,F
	    INCF		FSR,F
	    
	    MOVF		FSR,W
	    XORLW		0XF0
	    
	    BTFSS		STATUS,Z
	    
	    GOTO		REP2
	    
	    BSF			STATUS,IRP	; Seteo IRP para dir indirecto
	    
	    MOVLW		0X10
	    MOVWF		FSR
	    
REP3	    MOVF		NUM,W
	    MOVWF		INDF
	    
	    INCF		NUM,F
	    INCF		FSR,F
	    
	    MOVF		FSR,W
	    XORLW		0X70
	    
	    BTFSS		STATUS,Z
	    
	    GOTO		REP3
	    
	    MOVLW		0X90
	    MOVWF		FSR
	    
REP4	    MOVF		NUM,W
	    MOVWF		INDF
	    
	    INCF		NUM,F
	    INCF		FSR,F
	    
	    MOVF		FSR,W
	    XORLW		0XF0
	    
	    BTFSS		STATUS,Z
	    
	    GOTO		REP4
	    
	    GOTO		$
	    
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
	    
SUBT25MS    ;Se agrega porque el programa la llama mediante una macro que utiliza T25MS
	    ; entonces aquí llamamos a la macro que implementa el T25MS
	    
	    END
