; Consigna:
; Escribir un código que haga lo siguiente:
; Que salte de la posición 0x000B a la dirección 0x0800,
; de la posición 0x0800 a la posición 0x1000, de la dirección 
; 0x1000 a la dirección 0x1F30 y finalmente de la dirección 
; 0x1F30 a la dirección 0x000B
	    
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
	    
	    MOVLW		0X08
	    MOVWF		PCLATH
	    CLRF		PCL		;PC = 0X    08	    00
	    
	    ORG			0X0800
	    
	    MOVLW		0X10
	    MOVWF		PCLATH
	    CLRF		PCL		;PC = 0X    10	    00
	    
	    ORG			0X1000
	    
	    MOVLW		0X1F
	    MOVWF		PCLATH
	    MOVLW		0X30
	    MOVWF		PCL		;PC = 0X    1F	    30
	    
	    ORG			0X1F30
	    
	    CLRF		PCLATH
	    MOVLW		0X0B
	    MOVWF		PCL
	    
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
