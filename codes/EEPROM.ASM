;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2014                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     UTILIZANDO A EEPROM                         *
;*	          NATHÁLIA DE VASCONCELOS SILVA                    *
;*     DESENVOLVIDO PELA QUEROPASSAR ENGENHARIA E CONSULTORIA      *
;*   VERSÃO: 1.0                           DATA: 22/02/19          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*   IMPLEMENTANDO UM SELECTION SORT EM ASSEMBLY                   *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <P12F675.INC>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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
		DADO		;ARMAZENA O DADO PARA A EEPROM
		;NOVAS VARIÁVEIS
		POS_EXT		;POSICAO DO "FOR" EXTERNO
		POS_INT		;POSICAO DO "FOR" INTERNO
		POS_MAX		;POSICAO DO VALOR MAXIMO
		VALOR_MAX	;VALOR MAXIMO
		AUX_VALOR	;VARIAVEL AUXILIAR 1
		AUX_GRAVACAO	;VARIAVEL AUXILIAR PARA SWAP
		

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
; INICIALIZAÇÃO DA EEPROM, DE ACORDO COM A DESCRIÇÃO NO ARQUIVO "Def_Rega_Formigas.inc"

;A PARTIR DO ENDEREÇO ZERO DA EEPROM, DADOS EM ORDEM ALEATÓRIA
	ORG 0x2100
	DE	0X89,0X1E,0X39,0X9F,0XC2,0X0C,0XAB,0X33,0X63,0XD3,0X95,0X7B,0X38,0XD6,0X1E,0X48
	DE	0XDB,0XD8,0X86,0XFD,0XA5,0XFC,0X0C,0XBE,0X68,0X9B,0XD9,0X10,0XD8,0XEC,0X90,0X91
	DE	0XAA,0XBB,0XCC,0XDD,0XEE,0XF1,0XC9,0X77

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
LE_EEPROM
;LER DADO DA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;DADO LIDO RETORNA EM W
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR		;INDICA O END. DE LEITURA
	BSF		EECON1,RD	;INICIA O PROCESSO DE LEITURA
	MOVF	EEDATA,W	;COLOCA DADO LIDO EM W
	BANK0				;POSICIONA PARA BANK 0
	RETURN

GRAVA_EEPROM
;ESCREVE DADO (DADO) NA EEPROM, CUJO ENDEREÇO É INDICADO EM W
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF		EECON1,WREN ;HABILITA ESCRITA
	BCF		INTCON,GIE	;DESLIGA INTERRUPÇÕES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF		EECON1,WR ;INICIA A ESCRITA
AGUARDA
	BCF	EECON1,WREN
	BTFSC	EECON1,WR ;TERMINOU?
	GOTO	AGUARDA
	;BSF		INTCON,GIE ;HABILITA INTERRUPÇÕES
	BANK0				;POSICIONA PARA BANK 0
	BCF	PIR1,EEIF
	RETURN
	
ATUALIZA_VALOR_MAX
	MOVFW	AUX_VALOR   ;VALOR QUE ESTÁ EM W É MAIOR
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
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	CALL	3FFh
	MOVWF	OSCCAL
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00000000'
	MOVWF	POS_EXT		;DEFINIR O CONTADOR DO "FOR" EXTERNO
	MOVLW	B'00000001'
	MOVWF	POS_INT		;DEFINIR O CONTADOR DO "FOR" INTERNO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
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
	SUBWF   POS_INT,W   ;CHECANDO SE CHEGAMOS À POS. 39 DA EEPROM
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
	SUBWF	POS_EXT,W   ;CHECANDO SE CHEGAMOS À POS. 39 DA EEPROM
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
