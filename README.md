# microcontroladores
Repositório com os trabalhos da disciplina de Microcontroladores, que aconteceu no período de 2018.2. Este curso foi ofertado pelo professor Dr. Mardson Amorim. A disciplina de Microcontroladores faz parte da grade curricular do bacharelado em Engenharia de Computação na Universidade Federal da Paraíba (UFPB).

Nas palavras de Chuck Palahniuk, Clube da Luta:

> Everything is a copy of a copy of a copy.

# especificação dos trabalhos

## bcd com PIC12F675

- Dado um valor em hexadecimal (1 byte), converter esse valor para a notação BCD.
- Considera-se que o valor a ser convertido estará armazenado no registrador WORK e, após a conversão, o valor será armazenado na variável DADO;
- Se o valor convertido for maior que 99, o registrador WORK será utilizado como byte complementar;
- Se o valor convertido for menor que 99, o registrador WORK deverá conter zero

## frequências com PIC12F675

Dado um sinal de onda quadrada, que opera em 4 diferentes frequências, identifique-as com a sinalização através de LEDs.

- As frequências a serem verificadas são: 5kHz, 10kHz, 20kHz e 30kHz;
- A porta de entrada que receberá o sinal deve ser através de GP2;
- Os LEDs devem ser ativados (ON) apenas para indicar sua frequência correspondente, de acordo com a tabela abaixo:

|        Tabela       |
|---------------------|
| GP0 ON para f=5kHz  |
| GP1 ON para f=10kHz |
| GP4 ON para f=20kHz |
| GP5 ON para f=30kHz | 

- A tolerância ao erro será uma variação de 10% sobre a frequência identificada;

## utilizando a EEPROM com PIC12F675

Gravar e recuperar dados na memória perene (EEPROM).
Medir o tempo para colocar em ordem decrescente dados previamente armazenados na EEPROM.

- Apague todos os leds;
- Considere 40 bytes já armazenados na EEPROM, a partir do endereço 00h;
- Acenda o led GP5 imediatamente antes de iniciar a ordenação para sinalizar o início do processo;
- Coloque-os em ordem decrescente;
- Apague o led GP5 imediatamente depois para sinalizar que a ordenação terminou;
- A medição será efetuada com o osciloscópio;
- Esta tarefa terá um ponto suplementar para 3 alunos que conseguirem os menores tempos.

Eu obtive um tempo de **381,07ms** nessa atividade. A dica que posso dar é: evite ao máximo leitura e escrita na memória, só o faça quando for extremamente necessário. Assim, o tempo de execução do seu algoritmo decairá _bastante_!
Outra dica valiosa é que você deve pesquisar por algoritmos na literatura que se adequem bem ao problema que você quer resolver. Escolhi o selection sort para tal.

## voltímetro com indicação em BCD com PIC12F675

- Conversão A/D deve ser efetuada, em modo cíclico e tão rápido quanto possível (limitado pela velocidade do microcontrolador);
- O valor da conversão A/D, de 0V a 5V, deve ser transformado para uma escala de 0 a 9, em valores inteiros. Veja a escala na tabela abaixo;
- O valor da escala a ser mostrado, de 0 a 9, deve ser representado na codificação BCD para ser conectado ao display de 7 segmentos (kit  didático do LABEC 2). Para que todos tenham a mesma conectividade, siga a seguinte configuração:
- GP0 → b0 (MENOS significativo) do BCD
- GP1 → b1 do BCD
- GP4 → b2 do BCD
- GP5 → b3 (MAIS significativo) do BCD
- A conversão A/D deve ser feita pela porta GP2;

| Valor da Tensão (V) | Valor mostrado no display |
|---------------------|---------------------------|
| AD <= 0,5           | 0                         |
| 0,5 < AD <= 1       | 1                         |
| 1,0 < AD <= 1,5     | 2                         |
| 1,5 < AD <= 2       | 3                         |
| 2 < AD <= 2,5       | 4                         |
| 2,5 < AD <= 3       | 5                         |
| 3 < AD <= 3,5       | 6                         |
| 3,5 < AD <= 4       | 7                         |
| 4 < AD <= 4,5       | 8                         |
| AD > 4,5            | 9                         |

## controlador com histerese: sensor LDR com PIC12F675

Implementar um sistema de controle de iluminação artificial para ambiente, utilizando o princípio da histerese para evitar a “flutuação” da comutação no valor de comparação. Para isso, serão utilizados dois valores distintos (Lmín e Lmáx) para definir uma faixa de comutação.

_Como funciona:_

- Condições iniciais 1:
- Supondo que a iluminação de controle do comparador está configurado para Lmáx;
- Supondo que a iluminação ambiente (LAMB), a ser comparada, é superior a Lmáx;
- Nessas condições:
- a iluminação artificial deve ser desligada;
- e altera-se a configuração do comparador para Lmín.

- Condições iniciais 2:
- Supondo que a iluminação de controle do comparador está configurado para Lmín;
- Supondo que a iluminação ambiente (LAMB), a ser comparada, é inferior a Lmin;
- Nessas condições:
- a iluminação artificial deve ser ligada;
- e altera-se a configuração do comparador para Lmáx
- Para qualquer outra condição diferente das descritas acima:
- Mantém o estado anterior de funcionamento da iluminação artificial (ligada ou desligada);
- Mantém o valor anterior de configuração do comparador (Lmín ou Lmáx).

_Especificações:_
- A conversão de iluminação (medida pelo LDR) para tensão (V) faz parte do projeto. Assim, a partir do LDR, faça o levantamento das especificações e as medidas que considerar necessárias.
- A escolha da equação do comparador deve ser justificada pela demonstração dos diferentes valores obtidos.
- GP1 deverá ser utilizado para receber o sinal do LDR;
- GP2 deverá ser utilizado para fornecer o sinal de controle.

## controlador de LED RGB com PIC12F675

Controle da cor e da intensidade do brilho de um LED RGB.

- Após o RESET, os LEDs deverão estar apagados;
- Duas chaves serão utilizadas para selecionar o LED que será ajustado, segundo a tabela:

| Chaves | Cor do LED |
|--------|------------|
| 00     | Desligados |
| 01     | Red        |
| 10     | Green      |
| 11     | Blue       |

- Um canal será utilizado para conversão A/D será utilizada para controlar a intensidade (duty cycle) do brilho do LED selecionado;
- A intensidade do LED ajustado deverá ser mantida após a alteração da seleção para outro LED;
- Quando houver duty cycle diferente de 100%, a frequência do sinal deve ser de 500Hz;
- GP0, GP1 e GP2 deverão ser utilizados para produzir os sinais PWM, respectivamente, para os LED R, G e B;
- GP3 e GP5 deverão ser utilizados para efetuar a seleção do LED que será ajustado;
- GP4 deverá ser utilizado efetuar a conversão A/D;

## sensor dht11 com PIC16F628A

Familiarização com o gerenciamento de energia, leitura dos dados do sensor DHT11.
O sensor DHT11 fornece, de forma digital, as medidas de umidade relativa e de temperatura. Tais medidas devem ser enviadas a display 7 segmentos, obedecendo, pelo menos, a todas as especificações descritas abaixo.

_Especificações:_

- O projeto deve utilizar o PIC16F628A;
- A comunicação com o sensor DHT11 deve obedecer às especificações fornecidas pelo respectivo datasheet;
- Para comunicação com o DHT11 a porta RA0 do PIC deve ser utilizada;
- Os valores de temperatura e umidade devem ser visualizados em 2 display de 7 segmentos;
- Quando RA1 for LOW, o valor da temperatura deve ser exibido;
- Quando RA1 for HIGH, o valor da umidade deve ser exibido;
- As medidas (umidade e temperatura) devem ser solicitadas ao DHT11 uma vez a cada 2 segundos (aproximadamente). Para essa temporização o watchdog deve ser utilizado;
- O microcontrolador deve permanecer em modo sleep enquanto não estiver em processo de aquisição e envio de dados ao LCD;
- A saída de clock (CLKOUT) deve estar ativa (via RA6) para que seja possível caracterizar o estado sleep.

## comunicação I2C com PIC16F628A

Implementação do protocolo I2C no modo SLAVE.

_Especificações:_
- O protocolo I2C deve ser implementado no PIC (16F628A) no modo SLAVE;
- O PIC deve receber um byte de endereço e sinalizar sua identificação através de um LED;
- Quando o endereço for identificado como correto, um ACK deve ser enviado e o sinal CLK deve forçado a LOW por 100 ms;
- Um LED deve indicar que o endereço correto foi recebido, mantendo-o aceso pelo mesmo tempo do ACK em LOW;
- Para padronizar a utilização das portas, deve ser adotado:
- RA0 - SCL
- RA1 - SDA
- RB7 - LED
- Endereço: (2A)h
