; Subrutinas de tiempo de una variable:
SUBT1V	MACRO	VAR1
	MOVLW	VAR1
	MOVWF	0X60
	CALL	ST1V
	ENDM
	
; Subrutinas de tiempo de dos variables:
SUBT2V  MACRO	VAR1,VAR2
	MOVLW	VAR2
	MOVWF	0X61
	MOVLW	VAR1
	MOVWF	0X62
	CALL	ST2V
        ENDM
	
; Subrutinas de tiempo de tres variabes:
SUBT3V  MACRO	VAR1,VAR2,VAR3
	MOVLW	VAR3
	MOVWF	0X64
        MOVLW	VAR2
	MOVWF	0X65
        MOVLW	VAR1
        MOVWF	0X66
        CALL	ST3V
	ENDM
	
; Macro para corregir los rebotes en la entrada de los puertos
PUSH_ANTIR  MACRO   PUERTO,PIN
	    BTFSS   PUERTO,PIN
	    GOTO    $-1
	    CALL    T25MS	;Si detecta 1 espera 25mS, tenemos en cuenta este ciclo
	    BTFSC   PUERTO,PIN
	    GOTO    $-1   
	    CALL    T25MS       ;Si detecta 0 espera 25mS, tenemos en cuenta este ciclo
	    ENDM	    
	    

