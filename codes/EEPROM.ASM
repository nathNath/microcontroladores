;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2014                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     UTILIZANDO A EEPROM                         *
;*	          NATH�LIA DE VASCONCELOS SILVA                    *
;*     DESENVOLVIDO PELA QUEROPASSAR ENGENHARIA E CONSULTORIA      *
;*   VERS�O: 1.0                           DATA: 22/02/19          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*   IMPLEMENTANDO UM SELECTION SORT EM ASSEMBLY                   *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <P12F675.INC>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

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
		DADO		;ARMAZENA O DADO PARA A EEPROM
		;NOVAS VARI�VEIS
		POS_EXT		;POSICAO DO "FOR" EXTERNO
		POS_INT		;POSICAO DO "FOR" INTERNO
		POS_MAX		;POSICAO DO VALOR MAXIMO
		VALOR_MAX	;VALOR MAXIMO
		AUX_VALOR	;VARIAVEL AUXILIAR 1
		AUX_GRAVACAO	;VARIAVEL AUXILIAR PARA SWAP
		

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
; INICIALIZA��O DA EEPROM, DE ACORDO COM A DESCRI��O NO ARQUIVO "Def_Rega_Formigas.inc"

;A PARTIR DO ENDERE�O ZERO DA EEPROM, DADOS EM ORDEM ALEAT�RIA
	ORG 0x2100
	DE	0X89,0X1E,0X39,0X9F,0XC2,0X0C,0XAB,0X33,0X63,0XD3,0X95,0X7B,0X38,0XD6,0X1E,0X48
	DE	0XDB,0XD8,0X86,0XFD,0XA5,0XFC,0X0C,0XBE,0X68,0X9B,0XD9,0X10,0XD8,0XEC,0X90,0X91
	DE	0XAA,0XBB,0XCC,0XDD,0XEE,0XF1,0XC9,0X77

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
LE_EEPROM
;LER DADO DA EEPROM, CUJO ENDERE�O � INDICADO EM W
;DADO LIDO RETORNA EM W
	ANDLW	.127		;LIMITA ENDERE�O MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR		;INDICA O END. DE LEITURA
	BSF		EECON1,RD	;INICIA O PROCESSO DE LEITURA
	MOVF	EEDATA,W	;COLOCA DADO LIDO EM W
	BANK0				;POSICIONA PARA BANK 0
	RETURN

GRAVA_EEPROM
;ESCREVE DADO (DADO) NA EEPROM, CUJO ENDERE�O � INDICADO EM W
	ANDLW	.127		;LIMITA ENDERE�O MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF		EECON1,WREN ;HABILITA ESCRITA
	BCF		INTCON,GIE	;DESLIGA INTERRUP��ES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF		EECON1,WR ;INICIA A ESCRITA
AGUARDA
	BCF	EECON1,WREN
	BTFSC	EECON1,WR ;TERMINOU?
	GOTO	AGUARDA
	;BSF		INTCON,GIE ;HABILITA INTERRUP��ES
	BANK0				;POSICIONA PARA BANK 0
	BCF	PIR1,EEIF
	RETURN
	
ATUALIZA_VALOR_MAX
	MOVFW	AUX_VALOR   ;VALOR QUE EST� EM W � MAIOR
	MOVWF	VALOR_MAX   ;ATUALIZANDO VALOR_MAX
	MOVFW	POS_INT	    ;MOVENDO O INDICE DA POS_INT ATUAL
	MOVWF	POS_MAX	    ;ATUALIZA O INDICE DA POS. MAXIMA
	RETURN


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	CALL	3FFh
	MOVWF	OSCCAL
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW	B'00000000'
	MOVWF	POS_EXT		;DEFINIR O CONTADOR DO "FOR" EXTERNO
	MOVLW	B'00000001'
	MOVWF	POS_INT		;DEFINIR O CONTADOR DO "FOR" INTERNO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	;CORPO DA ROTINA PRINCIPAL
	
	BSF	GPIO,GP5    ;LIGA O GP5 PARA INDICAR O INICIO DA ORDENACAO

FOR_EXTERNO	
	
	MOVFW	POS_EXT     ;ATUALIZA O INDICE DA POS. EXTERNA
	MOVWF	POS_MAX	    ;ATUALIZA O INDICE DA POS. MAXIMA
	CALL	LE_EEPROM   ;LE O DADO NO INDICE DA POS. EXTERNA
	MOVWF	VALOR_MAX   ;ATUALIZA O VALOR_MAX COM O VALOR LIDO

FOR_INTERNO	
	MOVFW	POS_INT	    ;ATUALIZA O INDICE DA POS. INTERNA
	CALL	LE_EEPROM   ;LE O DADO NO INDICE DA POS_EXT+1
	MOVWF	AUX_VALOR   ;GUARDANDO TEMPORIAMENTE O VALOR LIDO
	SUBWF	VALOR_MAX,W
	BTFSS	STATUS,C    ;TESTAR SE VALOR[POS_INT] > VALOR_MAX
	CALL	ATUALIZA_VALOR_MAX ;SE FOR, ATUALIZAR O VALOR_MAX
	INCF	POS_INT,1   ;SENAO INCREMENTAR O CONTADOR DA POS. INTERNA
	;VALIDANDO SE NAO ESTAMOS OUT OF BOUNDS
	MOVLW	.39
	SUBWF   POS_INT,W   ;CHECANDO SE CHEGAMOS � POS. 39 DA EEPROM
	BTFSS	STATUS,Z    ;SE Z = 1
	GOTO	FOR_INTERNO ;SENAO EXECUTAR FOR_INTERNO

	;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	;*                       GRAVAR NA EEPROM                          *
	;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVFW	POS_EXT	    ;ESPECIFICANDO O ENDERECO PARA LEITURA DO DADO
	CALL	LE_EEPROM
	MOVWF	AUX_GRAVACAO;MOVER O QUE LI PARA AUX_GRAVACAO
	MOVWF	DADO	    ;MOVENDO O W PARA DADO A SER GRAVADO NA EEPROM 
	MOVFW	POS_MAX	    ;ESPECIFICANDO O ENDERECO A GRAVAR O DADO
	CALL	GRAVA_EEPROM
	CLRF	DADO	    ;LIMPAR DADO	
	
	MOVFW	VALOR_MAX   ;MOVENDO O VALOR_MAX PARA W
	MOVWF	DADO	    ;MOVENDO O W PARA DADO A SER GRAVADO NA EEPROM 
	MOVFW	POS_EXT	    ;ESPECIFICANDO O ENDERECO A GRAVAR O DADO
	CALL	GRAVA_EEPROM
	CLRF	DADO	    ;LIMPAR DADO
	
	
	
	CLRF	POS_INT	    ;PREPARAR POS_INT
	INCF	POS_EXT,1   ;INCREMENTAR O CONTADOR DA POS. EXTERNA
	MOVFW	POS_EXT
	MOVWF	POS_INT
	INCF	POS_INT,1   ;ATUALIZAR POS_INT PARA A POS_EXT+1
	;VALIDANDO SE NAO ESTAMOS OUT OF BOUNDS
	MOVLW	.39	    ;TAMANHO FINAL DO VETOR DA EEPROM
	SUBWF	POS_EXT,W   ;CHECANDO SE CHEGAMOS � POS. 39 DA EEPROM
	BTFSS	STATUS,Z    ;SE Z = 1
	GOTO	FOR_EXTERNO ;SENAO EXECUTAR FOR_EXTERNO
	BCF	GPIO,GP5    ;DESLIGA O GP5 PARA INDICAR O FIM DA ORDENACAO
	GOTO	FIM
	

FIM
	GOTO FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
