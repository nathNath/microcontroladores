;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DHT11 COM PIC16F628A                        *
;*                 NATH�LIA DE VASCONCELOS SILVA                   *
;*      DESENVOLVIDO PELA QUERO PASSAR ENGENHARIA E CONSULTORIA    *
;*   VERS�O: 1.0                           DATA: 22/04/19          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 16F628A                                     *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p16f628a.inc>	;ARQUIVO PADR�O MICROCHIP PARA 16F628A

    __CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_OFF & _INTOSC_OSC_CLKOUT & _LVP_OFF

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE BANK1   BSF STATUS,RP0  ;SETA BANK 1 DE MEM�RIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		;NOVAS VARI�VEIS
		CONTADOR
		CONT
		ADDR
		TESTE
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
	BCF	INTCON,T0IF	;LIMPAR A FLAG DA INTERRUP��O DO TMR0
	BTFSS	INTCON,T0IF
	GOTO	$-1		;VOLTAR PARA A INSTRU��O ANTERIOR ENQUANTO
				;O TMR0 N�O GERAR INTERRUP��O
	BANK0
	GOTO	DELAY_TIMER
	
SINAL_INICIO
	BANK1
	BCF	TRISA,RA0	;SETAR RA0 COMO SAIDA	
	BCF	INTCON,T0IF	;LIMPAR A FLAG DA INTERRUP��O DO TMR0
	BANK0
	BCF	PORTA,RA0	;ENVIAR SINAL LOW
	MOVLW	B'00110110'
	MOVWF	TMR1L
	MOVLW	B'11110111'
	MOVWF	TMR1H		;CONFIGURANDO O TMR1 PARA 63286 PARA ESPERAR 18MS
	BCF	PIR1,TMR1IF	;LIMPAR A FLAG DA INTERRUP��O DO TMR1
	BTFSS	PIR1,TMR1IF
	GOTO	$-1		;VOLTAR ENQUANTO TMR1 N�O GERAR INTERRUP��O
	BSF	TRISA,RA0	;SETAR RA0 COMO ENTRADA
	
;*********************** INICIO DA AQUISICAO DA LEITURA *****************************;
;*  80US EM LOW E 80US S�O ENVIADOS PELO DHT11 PARA CARACTERIZAR UM INICIO DE ENVIO *;
;************************************************************************************;

RESPOSTA_INICIO	
	BCF	INTCON,T0IF	;LIMPAR A FLAG DA INTERRUP��O DO TMR0
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
	MOVWF	OPTION_REG 	;DEFINE OP��ES DE OPERA��O	
	MOVLW	B'10100000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'00000001'
	MOVWF	PIE1		;DEFINE OP��ES DE INTERRUP��ES PERIF�RICAS
	BANK0			;RETORNA PARA O BANCO		
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW	B'00110001'	;PRESCALER 1:8 DO TMR1
	MOVWF	T1CON
		
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
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