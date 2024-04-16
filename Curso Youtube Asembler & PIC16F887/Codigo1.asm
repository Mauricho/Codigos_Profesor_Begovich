; Sacar por el puerto B el valor 0x55
; Sacar por el puerto C el valor 0xAA
; Sacar por el puerto D el valor 0xCC
    
    ;	**** Encabezado ****
    LIST P=16F887	  ;Le indico la matrícula del micro que estamos usando
    #include p16f887.inc  ;Contiene los nombres de los SFR de la RAM
    
    ;	**** Configuración General ****
    __Config 0x2007,23E4
    __Config 0x2008,3FFF 
    
    org 0x0000		  ;Quemamos el programa a partir de la dirección 0000
    
    ;Nota: Primero colocar el valor en el puerto despues configurarlo como
    ;	   salida, esto para evitar que entre ruido.
    
    ; ---- Cargamos los valores en los puertos, ya que estamos en el Banco 00
    MOVLW 0X55
    MOVWF PORTB		  ;Puerto B cargado con 0x55
    
    MOVLW 0XAA
    MOVWF PORTC		  ;Puerto C cargado con 0xAA 
    
    MOVLW 0XCC
    MOVWF PORTD		  ;Puerto D cargado con 0xCC
    
    ; ---- Configuramos los puertos A, B como digitales
    BSF STATUS, RP1
    BSF STATUS, RP0	  ;Estamos en la banco 3
    
    CLRF ANSEL		  ;Colocamos el puerto A como digital  
    CLRF ANSELH		  ;Colocamos el puerto B como digital
    
    ; ---- Configuramos los puertos B, C y D como salida
    BCF STATUS, RP1	  ;Estamos en la banco 1
    
    CLRF TRISA		  ;Colocamos el puerto A como salida 
    CLRF TRISB		  ;Colocamos el puerto B como salida  
    CLRF TRISC		  ;Colocamos el puerto C como salida
    CLRF TRISD		  ;Colocamos el puerto D como salida
    
    GOTO $		  ;Bucle para que el programa se bloquee.
    
    END
    
    
    
    

    

    

    
    

    


