;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     I2C COM PIC16F628A                          *
;*                 NATH�LIA DE VASCONCELOS SILVA                   *
;*      DESENVOLVIDO PELA QUERO PASSAR ENGENHARIA E CONSULTORIA    *
;*   VERS�O: 1.0                           DATA: 02/05/19          *
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

    __CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT & _LVP_OFF

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
		ENDERECO	;VARIAVEL PARA ARMAZENAR O DADO RECEBIDO PELO MASTER
		CONTADOR	;VARIAVEL AUXILIAR PARA AJUDAR NO PROCESSO DE CONTAGEM

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
	
#DEFINE END_SLAVE   H'2A'   ;42 EM DECIMAL

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	
#DEFINE	SCL PORTA,RA0	    ;RA0 SERA A ENTRADA DO SCL
#DEFINE	SCL_IO TRISA,TRISA0 ;CONTROL BIT DE ENTRADA E SAIDA DO SCL
#DEFINE	SDA PORTA,RA1	    ;RA1 SERA A ENTRADA DO SDA
#DEFINE	SDA_IO TRISA,TRISA1 ;CONTROL BIT DE ENTRADA E SAIDA DO SDA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE	LED PORTB,RB7	;LED A SER LIGADO
	
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
	
RESPOSTA_INICIO	;A ROTINA RESPOSTA_INICIO CONSISTE EM RESPOSTA_INICIO
	CLRF	ENDERECO    ;LIMPAR VARIAVEL QUE RECEBERA OS DADOS
	MOVLW	.8	    ;QUANTIDADE DE VEZES QUE DEVEMOS ITERAR PARA CONSTRUIR 1 BYTE
	MOVWF	CONTADOR
COMECO_SCL
	BTFSC	SCL	    ;ESPERA OCUPADA DA BORDA DE DESCIDA DO SCL
	GOTO	$-1
	BTFSS	SCL	    ;ESPERA OCUPADA DA BORDA DE SUBIDA DO SCL
	GOTO	$-1
	BCF	STATUS,C    ;LIMPAR CARRY
	BTFSC	SDA	    ;SE SDA = 0
	BSF	STATUS,C    ;SETAR CARRY
	RLF	ENDERECO    ;ROTACIONA CARRY PARA O ENDERECO
	DECFSZ	CONTADOR    ;DECREMENTAR CONTADOR
	GOTO	COMECO_SCL  ;LEITURA DO PROXIMO BIT
	RETURN		    ;SE FOR ZERO, ISSO INDICA QUE CONCLUIMOS A CODIFICACAO DO DADO EM 1 BYTE
			    ;ENTAO DEVEMOS VOLTAR PARA A ROTINA PRINCIPAL


TAREFA		;A ROTINA TAREFA CONSISTE EM ENVIAR O ACKNOWLEDGE, LIGAR O LED, ESPERAR 100MS, DESLIGAR O LED	
	;ENVIAR ACKNOWLEDGE
	BTFSC	SCL	;ESPERA A BORDA DE DESCIDA DO SCL
	GOTO	$-1
	BANK1
	BCF	SDA_IO	;MUDAR ESTADO DO SDA PARA OUTPUT
	BANK0
	BCF	SDA	;SDA PARA LOW	
	BTFSC	SCL	;ESPERA A BORDA DE DESCIDA DO SCL
	GOTO	$-1
	BTFSS	SCL	;ESPERA A BORDA DE SUBIDA DO SCL
	GOTO	$-1
	BTFSC	SCL	;ESPERA A BORDA DE DESCIDA DO SCL
	GOTO	$-1
	BCF	SCL	;SCL PARA LOW
	BANK1
	BCF	SCL_IO	;MUDAR ESTADO DO SCL PARA OUTPUT
	BSF	SDA_IO	;MUDAR ESTADO DO SDA PARA INPUT
	BANK0
	BCF	SCL	;SCL PARA LOW
	BSF	LED	;LIGAR O LED
	;FORCAR LOW POR 100MS
	BCF	PIR1,TMR1IF ;LIMPAR A FLAG DA INTERRUPCAO DO TMR1
	MOVLW	H'9E'
	MOVWF	TMR1H
	MOVLW	H'34'
	MOVWF	TMR1L
	BTFSS	PIR1,TMR1IF ;TESTAR SE A INTERRUPCAO DO TMR1 ACONTECEU
	GOTO	$-1
	BCF	LED	;DESLIGAR O LED
	BANK1
	BSF	SCL_IO	;MUDAR ESTADO DO SCL PARA INPUT
	BANK0
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00100011'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS), RA0 E RA1 COMO ENTRADA (SCL E SDA)
	MOVWF	TRISA			
	MOVLW	B'00000000'	;RB7 COMO SA�DA (LED)
	MOVWF	TRISB		
	MOVLW	B'00000000'	
	MOVWF	OPTION_REG 	;DEFINE OP��ES DE OPERA��O	
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0			;RETORNA PARA O BANCO		
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW	B'00100001'	;TMR1 CONFIGURADO COM O PRESCALER 1:4
	MOVWF	T1CON
		
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN	
	;ROTINA PRINCIPAL
	BTFSS	SDA		;ESPERA OCUPADA DA BORDA DE SUBIDA DO SDA
	GOTO	$-1
	BTFSC	SDA		;ESPERA OCUPADA DA BORDA DE DESCIDA DO SDA
	GOTO	$-1
	BTFSS	SCL		;ESPERA A BORDA DE SUBIDA DO SCL
	GOTO	MAIN		;VOLTAR PARA ESPERAR O ENVIO DO SDA
	CALL	RESPOSTA_INICIO	;CASO TENHA BORDA DE SUBIDA DO SCL, ADQUIRIR RESPOSTA COM A ROTINA RESPOSTA_INICIO
	BCF	STATUS,C	;LIMPAR CARRY
	RRF	ENDERECO	;COMO ROTACIONAMOS PARA A ESQUERDA NA HORA DA CODIFICACAO DOS DADOS
				;DEVEMOS ROTACIONAR PARA O SENTIDO CONTRARIO NA HORA DA DECODIFICACAO DOS DADOS
	MOVLW	END_SLAVE	;END_SLAVE ESTA CONFIGURADO PARA H'2A'
	SUBWF	ENDERECO,W	;SUBTRARIR ENDERECO - END_SLAVE
	BTFSC	STATUS,Z	;SE Z = 0, ENTAO ENDERECO == END_SLAVE
	CALL	TAREFA		;A ROTINA TAREFA CONSISTE EM ENVIAR O ACKNOWLEDGE, LIGAR O LED, ESPERAR 100MS, DESLIGAR O LED
	GOTO	MAIN		;VOLTAR PARA ESPERAR UM NOVO ENVIO DO SDA 

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END