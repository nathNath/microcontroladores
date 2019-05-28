;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2016                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           LED RGB                               *
;*                  NATHÁLIA DE VASCONCELOS SILVA                  *
;*         DESENVOLVIDO PELA QUERO PASSAR ENGENHARIA E CONSULTORIA *
;*   VERSÃO: 1.0                           DATA: 29/03/19          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_OFF & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		COUNT

		;NOVAS VARIÁVEIS

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÁ ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

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
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

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
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10100000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
;	CALL	0x03FF
;	MOVWF	OSCCAL
	BANK0				;RETORNA PARA O BANCO 0
	MOVLW	B'00001101'	;DEFINE OPÇÕES DE CONTROLE A/D
	MOVWF	ADCON0
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
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
    GOTO	DESLIGA_LED_VERMELHO ;SE ADRESH=0, ENTÃO DESLIGAR LED
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
    GOTO	DESLIGA_LED_VERDE ;SE ADRESH=0, ENTÃO DESLIGAR LED
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
    GOTO	DESLIGA_LED_AZUL ;SE ADRESH=0, ENTÃO DESLIGAR LED
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
