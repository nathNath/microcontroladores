;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2016                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           LED RGB                               *
;*                  NATH�LIA DE VASCONCELOS SILVA                  *
;*         DESENVOLVIDO PELA QUERO PASSAR ENGENHARIA E CONSULTORIA *
;*   VERS�O: 1.0                           DATA: 29/03/19          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_OFF & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		COUNT

		;NOVAS VARI�VEIS

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER� ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

	BTFSS	GPIO,GP3    ;TESTA O ESTADO DA CHAVE EM GP3
	GOTO	INT_TESTE_OFF_VERMELHO		
	GOTO	INT_TESTA_VERDE_AZUL
	
INT_TESTE_OFF_VERMELHO
	
    BTFSS	GPIO,GP5    ;TESTA O ESTADO DA CHAVE EM GP5
    GOTO	INT_DESLIGADO   ;CASO 00 (AJUSTAR PARA DESLIGAR)
    GOTO	INT_VERMELHO    ;CASO 01 (AJUSTAR LED VERMELHO)
	
INT_TESTA_VERDE_AZUL
	
    BTFSS	GPIO,GP5    ;TESTA O ESTADO DA CHAVE EM GP5	
    GOTO	INT_VERDE	    ;CASO 10 (AJUSTAR LED VERDE)
    GOTO	INT_AZUL	    ;CASO 11 (AJUSTAR LED AZUL)
    
INT_VERMELHO

    BSF		GPIO,GP0
    CLRF	TMR0
    MOVFW	ADRESH
    MOVWF	COUNT
	
LOOP_VERMELHO
	NOP
	NOP
	NOP
	NOP
	DECFSZ	COUNT,F
	GOTO	LOOP_VERMELHO
	BCF	GPIO,GP0		;DESLIGAR O LED VERMELHO
	BANK1
	BCF	INTCON,T0IF	;LIMPAR FLAG DE INTERRUPCAO
	BANK0
	GOTO	SAI_INT
    
    
INT_VERDE
	
    BSF	GPIO,GP1
    CLRF	TMR0
    MOVFW	ADRESH
    MOVWF	COUNT
	
LOOP_VERDE
	NOP
	NOP
	NOP
	NOP
	DECFSZ	COUNT,F
	GOTO	LOOP_VERDE
	BCF	GPIO,GP1		;DESLIGAR O LED VERDE
	BANK1
	BCF	INTCON,T0IF	;LIMPAR FLAG DE INTERRUPCAO
	BANK0
	GOTO	SAI_INT
    
INT_AZUL
	
    BSF	GPIO,GP2
    CLRF	TMR0
    MOVFW	ADRESH
    MOVWF	COUNT
	
LOOP_AZUL
	NOP
	NOP
	NOP
	NOP
	DECFSZ	COUNT,F
	GOTO	LOOP_AZUL
	BCF	GPIO,GP2		;DESLIGAR O LED AZUL
	BANK1
	BCF	INTCON,T0IF	;LIMPAR FLAG DE INTERRUPCAO
	BANK0	
	GOTO	SAI_INT
	
INT_DESLIGADO

    BCF	GPIO,GP0
    BCF	GPIO,GP1
    BCF	GPIO,GP2
    CLRF	TMR0
    MOVFW	ADRESH
    MOVWF	COUNT
	
LOOP_DESLIGADO
	NOP
	NOP
	NOP
	NOP
	DECFSZ	COUNT,F
	GOTO	LOOP_DESLIGADO
	BCF	GPIO,GP0		;DESLIGAR O LED VERMELHO
	BCF	GPIO,GP1		;DESLIGAR O LED VERDE
	BCF	GPIO,GP2		;DESLIGAR O LED AZUL
	BANK1
	BCF	INTCON,T0IF	;LIMPAR FLAG DE INTERRUPCAO
	BANK0



;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00111000'     ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO ENTRADAS
	MOVLW	B'00011000'	;CONFIGURA A/D PARA FOSC/8 E HABILITA ANS3
	MOVWF	ANSEL 		
	MOVLW	B'00000010'	;CONFIGURA PRESCALER PARA 1:8 DO MODULO TMR0
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'10100000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
;	CALL	0x03FF
;	MOVWF	OSCCAL
	BANK0				;RETORNA PARA O BANCO 0
	MOVLW	B'00001101'	;DEFINE OP��ES DE CONTROLE A/D
	MOVWF	ADCON0
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	CLRF	TMR0	    ;LIMPA O TIMER
	CLRF	GPIO	    ;TODOS OS LEDS DEVEM ESTAR APAGADOS AO RESETAR
	
MAIN

    ;CORPO DA ROTINA PRINCIPAL
    
    BTFSS	GPIO,GP3    ;TESTA O ESTADO DA CHAVE EM GP3
    GOTO	TESTE_OFF_VERMELHO		
    GOTO	TESTA_VERDE_AZUL

	
TESTE_OFF_VERMELHO
	
    BTFSS	GPIO,GP5    ;TESTA O ESTADO DA CHAVE EM GP5
    GOTO	DESLIGADO   ;CASO 00 (AJUSTAR PARA DESLIGAR)
    GOTO	VERMELHO    ;CASO 01 (AJUSTAR LED VERMELHO)
	
TESTA_VERDE_AZUL
	
    BTFSS	GPIO,GP5    ;TESTA O ESTADO DA CHAVE EM GP5	
    GOTO	VERDE	    ;CASO 10 (AJUSTAR LED VERDE)
    GOTO	AZUL	    ;CASO 11 (AJUSTAR LED AZUL)
	
VERMELHO
	
    BSF		ADCON0,GO   ;INICIALIZA A CONVERSAO AD
    
CONVERSAO_VERMELHO
    BTFSC	ADCON0,GO   ;TESTA A FLAG GO/DONE 
    GOTO	CONVERSAO_VERMELHO
    MOVLW	.249
    SUBWF	ADRESH,W
    BTFSC	STATUS,C
    GOTO	LIGA_LED_VERMELHO
    MOVLW	.1
    SUBWF	ADRESH,W
    BTFSS	STATUS,C
    GOTO	DESLIGA_LED_VERMELHO ;SE ADRESH=0, ENT�O DESLIGAR LED
    GOTO	MAIN
    
LIGA_LED_VERMELHO
    CLRF	TMR0 
    BSF		GPIO,GP0
    GOTO	MAIN

DESLIGA_LED_VERMELHO
    CLRF	TMR0
    BCF		GPIO,GP0
    GOTO	MAIN
	
VERDE

    BSF		ADCON0,GO   ;INICIALIZA A CONVERSAO AD
    
CONVERSAO_VERDE
    BTFSC	ADCON0,GO   ;TESTA A FLAG GO/DONE 
    GOTO	CONVERSAO_VERDE
    MOVLW	.249
    SUBWF	ADRESH,W
    BTFSC	STATUS,C
    GOTO	LIGA_LED_VERDE
    MOVLW	.1
    SUBWF	ADRESH,W
    BTFSS	STATUS,C
    GOTO	DESLIGA_LED_VERDE ;SE ADRESH=0, ENT�O DESLIGAR LED
    GOTO	MAIN
    
LIGA_LED_VERDE
    CLRF	TMR0 
    BSF		GPIO,GP1
    GOTO	MAIN

DESLIGA_LED_VERDE
    CLRF	TMR0
    BCF		GPIO,GP1
    GOTO	MAIN

	
AZUL
	
    BSF		ADCON0,GO   ;INICIALIZA A CONVERSAO AD
    
CONVERSAO_AZUL
    BTFSC	ADCON0,GO   ;TESTA A FLAG GO/DONE 
    GOTO	CONVERSAO_AZUL
    MOVLW	.249
    SUBWF	ADRESH,W
    BTFSC	STATUS,C
    GOTO	LIGA_LED_AZUL	;C=1, LIGAR    
    MOVLW	.1		;C=0, ADRESH<W
    SUBWF	ADRESH,W
    BTFSS	STATUS,C
    GOTO	DESLIGA_LED_AZUL ;SE ADRESH=0, ENT�O DESLIGAR LED
    GOTO	MAIN
    
LIGA_LED_AZUL
    CLRF	TMR0 
    BSF		GPIO,GP2
    GOTO	MAIN

DESLIGA_LED_AZUL
    CLRF	TMR0
    BCF		GPIO,GP2
    GOTO	MAIN    

	
DESLIGADO
    BCF		GPIO,GP0	    ;DESLIGAR GP0
    BCF		GPIO,GP1	    ;DESLIGAR GP1
    BCF		GPIO,GP2	    ;DESLIGAR GP2
    GOTO	MAIN
    


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
