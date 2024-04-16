; Son definiciones para el manejo de los displays 7 segmento
    #DEFINE	UNID_E	    BSF	    PORTA,0
    #DEFINE	UNID_A	    BCF	    PORTA,0
    #DEFINE	DECE_E	    BSF	    PORTA,1
    #DEFINE	DECE_A	    BCF	    PORTA,1
	    
; Son definiciones para el manejo del LCD
    #DEFINE	RS_0	    BCF	    PORTB,4	    ;RS en 0
    #DEFINE	RS_1	    BSF	    PORTB,4	    ;RS en 1
    #DEFINE	E_0	    BCF	    PORTB,5	    ;E en 0
    #DEFINE	E_1	    BSF	    PORTB,5	    ;E en 1
	    
;   Lo utilizo para los displays de 7 segmento	    
    UNID		    EQU	    0X20
    DECE		    EQU	    0X21
    CONT60		    EQU	    0X22

;   Lo utilizo para la LCD	    
    UNID_L		    EQU	    0X25
    DECE_L		    EQU	    0x26
    CENT_L		    EQU	    0x27
    DATO		    EQU	    0X2A

;   Contador para llegar a 2500 eventos
    CONT5		    EQU	    0X23

;   Contador para los números aleatorios
    ALEA		    EQU	    0X24
