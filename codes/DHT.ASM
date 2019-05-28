;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DHT11 COM PIC16F628A                        *
;*                 NATHÁLIA DE VASCONCELOS SILVA                   *
;*      DESENVOLVIDO PELA QUERO PASSAR ENGENHARIA E CONSULTORIA    *
;*   VERSÃO: 1.0                           DATA: 22/04/19          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 16F628A                                     *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p16f628a.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 16F628A

    __CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_OFF & _INTOSC_OSC_CLKOUT & _LVP_OFF

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE BANK1   BSF STATUS,RP0  ;SETA BANK 1 DE MEMÓRIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		;NOVAS VARIÁVEIS
		CONTADOR
		CONT
		ADDR
		TESTE
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
	
	MOVLW	.61
	MOVWF	CONTADOR	;CONFIGURAR O CONTADOR
	
DELAY_TIMER
	DECFSZ	CONTADOR
	GOTO	CONFIGURA_TMR
	GOTO	SINAL_INICIO
	
CONFIGURA_TMR
	MOVLW	.0
	MOVWF	TMR0		;CONFIGURAR O TEMPO NO TMR0 COM ZERO
	BANK1
	BCF	INTCON,T0IF	;LIMPAR A FLAG DA INTERRUPÇÃO DO TMR0
	BTFSS	INTCON,T0IF
	GOTO	$-1		;VOLTAR PARA A INSTRUÇÃO ANTERIOR ENQUANTO
				;O TMR0 NÃO GERAR INTERRUPÇÃO
	BANK0
	GOTO	DELAY_TIMER
	
SINAL_INICIO
	BANK1
	BCF	TRISA,RA0	;SETAR RA0 COMO SAIDA	
	BCF	INTCON,T0IF	;LIMPAR A FLAG DA INTERRUPÇÃO DO TMR0
	BANK0
	BCF	PORTA,RA0	;ENVIAR SINAL LOW
	MOVLW	B'00110110'
	MOVWF	TMR1L
	MOVLW	B'11110111'
	MOVWF	TMR1H		;CONFIGURANDO O TMR1 PARA 63286 PARA ESPERAR 18MS
	BCF	PIR1,TMR1IF	;LIMPAR A FLAG DA INTERRUPÇÃO DO TMR1
	BTFSS	PIR1,TMR1IF
	GOTO	$-1		;VOLTAR ENQUANTO TMR1 NÃO GERAR INTERRUPÇÃO
	BSF	TRISA,RA0	;SETAR RA0 COMO ENTRADA
	
;*********************** INICIO DA AQUISICAO DA LEITURA *****************************;
;*  80US EM LOW E 80US SÃO ENVIADOS PELO DHT11 PARA CARACTERIZAR UM INICIO DE ENVIO *;
;************************************************************************************;

RESPOSTA_INICIO	
	BCF	INTCON,T0IF	;LIMPAR A FLAG DA INTERRUPÇÃO DO TMR0
	BANK0
	CLRF	ADDR
	MOVLW	.8	
	MOVWF	CONT
	
RESPOSTA_LOOP
	BTFSC	PORTA,RA0	;ESPERA BORDA DE DESCIDA DO RA0
	GOTO	$-1
	BTFSS	PORTA,RA0	;ESPERA BORDA DE SUBIDA DO RA0
	GOTO	$-1
	BTFSC	PORTA,RA0	;ESPERA BORDA DE DESCIDA DO RA0	
	GOTO	$-1
	
RESPOSTA_BIT
	BTFSS	PORTA,RA0	;ESPERA BORDA DE SUBIDA DO RA0
	GOTO	$-1
	INCF	TESTE		;INCREMENTA TESTE
	BTFSC	PORTA,RA0	;ESPERA BORDA DE DESCIDA DO RA0
	GOTO	$-2
	
	BTFSS	PORTA,RA1	;TESTAR SWITCH
	GOTO	TEMPERATURA	
	GOTO	UMIDADE		
	
UMIDADE				;LER OS OITO PRIMEIROS BITS DA RESPOSTA DO DHT11
	MOVLW	.10
	SUBWF	TESTE		
	BTFSC	STATUS,C	;TESTE > 10 (40US)?
	GOTO	SET_HIGH	;SE C=1, TESTE >= 10 (40US)
	GOTO	SET_LOW		;SE C=0, TESTE < 10 (40US)
	
SET_HIGH
	RLF	ADDR		;ROTACIONA CARRY PARA REGISTRADOR ADDR
	DECFSZ	CONT		;REPETE POR 8 VEZES
	GOTO	RESPOSTA_BIT
	MOVFW	ADDR		
	MOVWF	PORTB		;EXIBINDO RESULTADO NO DISPLAY
	CLRF	PORTB		;LIMPAR DISPLAY
	GOTO	SAI_INT

SET_LOW
	RLF	ADDR		;ROTACIONA CARRY PARA REGISTRADOR ADDR
	DECFSZ	CONT		;REPETE POR 8 VEZES
	GOTO	RESPOSTA_BIT	
	MOVFW	ADDR		
	MOVWF	PORTB		;EXIBINDO RESULTADO NO DISPLAY
	CLRF	PORTB		;LIMPAR DISPLAY
	GOTO	SAI_INT
	
TEMPERATURA			;LER DOS BITS 16 A 23 DA RESPOSTA DO DHT11
	MOVLW	.10
	SUBWF	TESTE		
	BTFSC	STATUS,C	;TESTE > 10 (40US)?
	GOTO	SET_HIGH	;SE C=1, TESTE >= 10 (40US)
	GOTO	SET_LOW		;SE C=0, TESTE < 10 (40US)
	
SET_HIGH_2
	RLF	ADDR		;ROTACIONA CARRY PARA REGISTRADOR ADDR
	DECFSZ	CONT		;REPETE POR 8 VEZES
	GOTO	RESPOSTA_BIT
	MOVFW	ADDR		
	MOVWF	PORTB		;EXIBINDO RESULTADO NO DISPLAY
	CLRF	PORTB		;LIMPAR DISPLAY
	GOTO	SAI_INT

SET_LOW_2
	RLF	ADDR		;ROTACIONA CARRY PARA REGISTRADOR ADDR
	DECFSZ	CONT		;REPETE POR 8 VEZES
	GOTO	RESPOSTA_BIT	
	MOVFW	ADDR		
	MOVWF	PORTB		;EXIBINDO RESULTADO NO DISPLAY
	CLRF	PORTB		;LIMPAR DISPLAY
	GOTO	SAI_INT
	
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

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00100010'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISA			
	MOVLW	B'00000000'
	MOVWF	TRISB		
	MOVLW	B'00000110'	;SELECIONAR O TMR0 COM PRESCALER 1:128
	MOVWF	OPTION_REG 	;DEFINE OPÇÕES DE OPERAÇÃO	
	MOVLW	B'10100000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'00000001'
	MOVWF	PIE1		;DEFINE OPÇÕES DE INTERRUPÇÕES PERIFÉRICAS
	BANK0			;RETORNA PARA O BANCO		
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00110001'	;PRESCALER 1:8 DO TMR1
	MOVWF	T1CON
		
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN	
	;ROTINA PRINCIPAL
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END