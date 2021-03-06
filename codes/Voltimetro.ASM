;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2016                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*            MEDICAO DE TENSAO E INDICACAO EM BCD                 *
;*                NATH�LIA DE VASCONCELOS SILVA                    *
;*       DESENVOLVIDO PELA QUEROPASSAR ENGENHARIA E CONSULTORIA    *
;*   VERS�O: 1.0                           DATA: 06/03/19          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*   MEDICAO DE TENSAO E INDICACAO EM BCD                          *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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
	MOVLW	B'00001100'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'00010100'
	MOVWF	ANSEL		;DEFINE OP��ES DE SELE��O ANAL�GICA
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW	B'00001001'
	MOVWF	ADCON0		;DEFINE OP��ES DE CONTROLADOR DA CONVERS�O A/D

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	BSF	ADCON0,1	    ;SETAR PARA 1 A FLAG GO/DONE

CONVERSAO			    ;LOOP DA CONVERSAO A/D
	BTFSC	ADCON0,1
	GOTO	CONVERSAO
	
	MOVLW	.26		    ;VERIFICANDO SE ADRESH <= 0,5V
	SUBWF	ADRESH,W
	BTFSS	STATUS,C
	GOTO	DISPLAY_ZERO	    ;SE C=0, ADRESH < W, DISPLAY_ZERO
	BTFSS	STATUS,Z	    ;SE C=1, TESTAR O Z
	GOTO	INTERVALO_UM	    ;SE Z=0, ADRESH > W, TESTAR PROX INTERVALO
	GOTO	DISPLAY_ZERO	    ;SE Z=1, ADRESH = W, DISPLAY_ZERO
	
INTERVALO_UM
	MOVLW	.51		    ;VERIFICANDO SE 0,5V < ADRESH <= 1V
	SUBWF	ADRESH,W
	BTFSS	STATUS,C
	GOTO	DISPLAY_UM	    ;SE C=0, ADRESH < W, DISPLAY_UM
	BTFSS	STATUS,Z	    ;SE C=1, TESTAR O Z
	GOTO	INTERVALO_DOIS	    ;SE Z=0, ADRESH > W, TESTAR PROX INTERVALO
	GOTO	DISPLAY_UM	    ;SE Z=1, ADRESH = W, DISPLAY_UM
	
INTERVALO_DOIS
	MOVLW	.77		    ;VERIFICANDO SE 1V < ADRESH <= 1,5V
	SUBWF	ADRESH,W
	BTFSS	STATUS,C
	GOTO	DISPLAY_DOIS	    ;SE C=0, ADRESH < W, DISPLAY_DOIS
	BTFSS	STATUS,Z	    ;SE C=1, TESTAR O Z
	GOTO	INTERVALO_TRES	    ;SE Z=0, ADRESH > W, TESTAR PROX INTERVALO
	GOTO	DISPLAY_DOIS	    ;SE Z=1, ADRESH = W, DISPLAY_DOIS
	
INTERVALO_TRES
	MOVLW	.102		    ;VERIFICANDO SE 1,5V < ADRESH <= 2V
	SUBWF	ADRESH,W
	BTFSS	STATUS,C
	GOTO	DISPLAY_TRES	    ;SE C=0, ADRESH < W, DISPLAY_TRES
	BTFSS	STATUS,Z	    ;SE C=1, TESTAR O Z
	GOTO	INTERVALO_QUATRO    ;SE Z=0, ADRESH > W, TESTAR PROX INTERVALO
	GOTO	DISPLAY_TRES	    ;SE Z=1, ADRESH = W, DISPLAY_TRES
	
INTERVALO_QUATRO
	MOVLW	.128		    ;VERIFICANDO SE 2V < ADRESH <= 2,5V
	SUBWF	ADRESH,W
	BTFSS	STATUS,C
	GOTO	DISPLAY_QUATRO	    ;SE C=0, ADRESH < W, DISPLAY_QUATRO
	BTFSS	STATUS,Z	    ;SE C=1, TESTAR O Z
	GOTO	INTERVALO_CINCO	    ;SE Z=0, ADRESH > W, TESTAR PROX INTERVALO
	GOTO	DISPLAY_QUATRO	    ;SE Z=1, ADRESH = W, DISPLAY_QUATRO
	
INTERVALO_CINCO
	MOVLW	.153		    ;VERIFICANDO SE 2,5V < ADRESH <= 3V
	SUBWF	ADRESH,W
	BTFSS	STATUS,C
	GOTO	DISPLAY_CINCO	    ;SE C=0, ADRESH < W, DISPLAY_CINCO
	BTFSS	STATUS,Z	    ;SE C=1, TESTAR O Z
	GOTO	INTERVALO_SEIS	    ;SE Z=0, ADRESH > W, TESTAR PROX INTERVALO
	GOTO	DISPLAY_CINCO	    ;SE Z=1, ADRESH = W, DISPLAY_CINCO
	
INTERVALO_SEIS
	MOVLW	.179		    ;VERIFICANDO SE 3V < ADRESH <= 3,5V
	SUBWF	ADRESH,W
	BTFSS	STATUS,C
	GOTO	DISPLAY_SEIS	    ;SE C=0, ADRESH < W, DISPLAY_SEIS
	BTFSS	STATUS,Z	    ;SE C=1, TESTAR O Z
	GOTO	INTERVALO_SETE	    ;SE Z=0, ADRESH > W, TESTAR PROX INTERVALO
	GOTO	DISPLAY_SEIS	    ;SE Z=1, ADRESH = W, DISPLAY_SEIS
	
INTERVALO_SETE
	MOVLW	.204		    ;VERIFICANDO SE 3,5V < ADRESH <= 4V
	SUBWF	ADRESH,W
	BTFSS	STATUS,C
	GOTO	DISPLAY_SETE	    ;SE C=0, ADRESH < W, DISPLAY_SETE
	BTFSS	STATUS,Z	    ;SE C=1, TESTAR O Z
	GOTO	INTERVALO_OITO	    ;SE Z=0, ADRESH > W, TESTAR PROX INTERVALO
	GOTO	DISPLAY_SETE	    ;SE Z=1, ADRESH = W, DISPLAY_SETE
	
INTERVALO_OITO
	MOVLW	.230		    ;VERIFICANDO SE 4V < ADRESH <= 4,5V
	SUBWF	ADRESH,W
	BTFSS	STATUS,C
	GOTO	DISPLAY_OITO	    ;SE C=0, ADRESH < W, DISPLAY_OITO
	BTFSS	STATUS,Z	    ;SE C=1, TESTAR O Z
	GOTO	INTERVALO_NOVE	    ;SE Z=0, ADRESH > W, TESTAR PROX INTERVALO
	GOTO	DISPLAY_OITO	    ;SE Z=1, ADRESH = W, DISPLAY_OITO
	
INTERVALO_NOVE
	GOTO	DISPLAY_NOVE
	
DISPLAY_ZERO
	BCF	GPIO,GP0
	BCF	GPIO,GP1
	BCF	GPIO,GP4
	BCF	GPIO,GP5
	GOTO	MAIN
	
DISPLAY_UM
	BSF	GPIO,GP0
	BCF	GPIO,GP1
	BCF	GPIO,GP4
	BCF	GPIO,GP5
	GOTO	MAIN
	
DISPLAY_DOIS
	BCF	GPIO,GP0
	BSF	GPIO,GP1
	BCF	GPIO,GP4
	BCF	GPIO,GP5
	GOTO	MAIN
	
DISPLAY_TRES
	BSF	GPIO,GP0
	BSF	GPIO,GP1
	BCF	GPIO,GP4
	BCF	GPIO,GP5
	GOTO	MAIN
	
DISPLAY_QUATRO
	BCF	GPIO,GP0
	BCF	GPIO,GP1
	BSF	GPIO,GP4
	BCF	GPIO,GP5
	GOTO	MAIN
	
DISPLAY_CINCO
	BSF	GPIO,GP0
	BCF	GPIO,GP1
	BSF	GPIO,GP4
	BCF	GPIO,GP5
	GOTO	MAIN
	
DISPLAY_SEIS
	BCF	GPIO,GP0
	BSF	GPIO,GP1
	BSF	GPIO,GP4
	BCF	GPIO,GP5
	GOTO	MAIN
	
DISPLAY_SETE
	BSF	GPIO,GP0
	BSF	GPIO,GP1
	BSF	GPIO,GP4
	BCF	GPIO,GP5
	GOTO	MAIN
	
DISPLAY_OITO
	BCF	GPIO,GP0
	BCF	GPIO,GP1
	BCF	GPIO,GP4
	BSF	GPIO,GP5
	GOTO	MAIN
	
DISPLAY_NOVE
	BSF	GPIO,GP0
	BCF	GPIO,GP1
	BCF	GPIO,GP4
	BSF	GPIO,GP5
	GOTO	MAIN
	
FIM
	GOTO	FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
