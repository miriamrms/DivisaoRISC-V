#==================================
#Obs: Para o input, digite um sinal (+ ou -) seguido de um numero ate 5 digitos, um espaço e mais outro sinal seguido de outro num de 5 digitos
#Exemplo: +2416 -12
#=================================

#inicializar valores para divisao
add x10, x10, x0        			 #resto e dividendo
add x11, x11, x0         		 #divisor
addi x13, x13, 18 							#contador
addi x12, x12, 0							#quociente
addi x14, x14, 0 							#sinal

#cria um vetor que armazena as potencias de 10 ate 10^9 pois o resultado pode ser até 10 digitos 
#utiliza o lui para armazenar nos 20 primeiros bits
#utiliza o add para armazenar nos 12 bits menos significativos
#lui só armazena numeros de ate 20 bits
#add só armazena numeros de ate 12 bits
#precisamos dos dois pois nao conseguimos armazenar numeros maiores que seu limite diretamente

lui x5, 0x3B9AC 						#10^9     
addi x5, x5, 0xA00						
sw x5, 0(x9)						

lui x5, 0x05F5E 						#10^8
addi x5, x5, 0x100
sw x5, 4(x9)

lui  x5, 0x00989 						#10^7
addi x5, x5, 0x680 
sw   x5, 8(x9)

lui  x5, 0x000f4 						#10^6
addi x5, x5, 0x240
sw   x5, 12(x9)

lui  x5, 0x00018 						#10^5
addi x5, x5, 0x6a0
sw   x5, 16(x9)

lui  x5, 0x00002 						#10^4
addi x5, x5, 0x710
sw   x5, 20(x9)

addi x5, x0, 1000 						#10^3
sw x5, 24(x9)

addi x5, x0, 100  						#10^2
sw   x5, 28(x9)

addi x5, x0, 10  						#10^1
sw   x5, 32(x9)

addi x5, x0, 1  						#10^0
sw   x5, 36(x9) 

#inicializar valores para leitura
addi x5, x0, 0					#conta quantos números foram lidos
add x30, x30, x0
add x31, x31, x0
addi x28, x0, 32 			#valor do espaco em ASCII
addi x29, x0, 45 			#valor de '-' em ASCII

#Ler input do teclado
lerSinal:
add x15, x0, x0
lb x7, 1025(x0)							#x7 guarda o valor do input
beq x7, x29, sinalNegativo		#se sinal = '-'
jal x1, lerNum

sinalNegativo:							
xori x14, x14, 1							#se é negativo muda o sinal
jal x1, lerNum

lerNum:
lb x7, 1025(x0)							#lê input do teclado
beq x7, x28, pararInput				 #se for espaço para de ler
beq x7, x0, pararInput					 #se não tiver mais entrada para de ler também

addi x7, x7, -48							#transforma de ASCII para número
slli x30, x15, 1							#multiplica por 2
slli x31, x15, 3							#multiplica por 8
add x15, x30, x31							#x15 = x15 x (2+8) -> multiplica por 10
add x15, x15, x7							#adiciona a nova entrada na unidade 
jal x1, lerNum

pararInput:
beq x5, x0, criarMultiplicando		#se é o primeiro num -> add em x10, multiplicando
add x11, x11, x15 							   	#senão, add em x11, multiplicador
jal x1, tratarDivisor

criarMultiplicando:
add x10, x10, x15 
addi x5, x5, 1
jal x1, lerSinal								#volta para ler o segundo número

tratarDivisor:
slli x11, x11, 17  #desloca o divisor 17 bits
jal x1, loop

loop:
sub x10, x10, x11 								#subtrai divisor do dividendo
blt x10, x0, restoMenorQueZero  #verifica se resto < 0
jal x1, restoMaiorIgualZero

restoMenorQueZero:
add x10, x10, x11          	#reseta o valor original do resto
slli x12, x12, 1						   	#desloca o quociente a esquerda
jal x1, deslocaDivisor

restoMaiorIgualZero:
slli x12, x12, 1        	#desloca o quociente a esquerda
ori x12, x12, 1         	#add o rightmost do quociente como 1
jal x1, deslocaDivisor

deslocaDivisor:
srli x11, x11, 1								#desloca o divisor a direita
addi x13, x13, -1								#decrementa o contador
beq x13, x0, imprimirSinal				  #se ja repetiu 18 vezes, imprime o num
jal x1, loop								#se nao, reinicia o loop


imprimirSinal:
beq x14, x0, imprimirPositivo		#se x14 = 0, sinal o positivo
addi x14, x0, 45							   #senao, x14 recebe 45 (valor que representa '-')
sb x14, 1024(x0)							   #imprime o sinal negativo
jal x1, imprimirNum						

imprimirPositivo:
addi x14, x0, 43						 #x14 = 43 (valor de '+')
sb x14, 1024(x0)						 #imprime sinal +
jal x1, imprimirNum

imprimirNum:
addi x5, x0, 0						#contador digitos lidos
addi x6, x0, 10						#quantidade maxima de digitos
addi x20, x12, 0						#salva o resultador

loopImprimir:
bge x5, x6, end						#se x5>=10 todos os dígitos foram impressos
slli x7, x5, 2 						#multiplica por 4 e guarda em x7 para acessar o espaço da memoria
add x7, x7, x9						#soma o endereco da potência de 10 correspondente com base no array
lw x7, 0(x7)						#armazena o valor da potência de 10
add x28, x0, x0						

dividirPotencia:
blt x20, x7, imprimirDigito		#x20 < potencia de 10? sim -> proximo digito
sub x20, x20, x7							#senao, subtrai a potencia de 10 o quanto puder
addi x28, x28, 1							#soma 1 a cada subtracao, ate encontrar o digito atual
jal x0, dividirPotencia     #chama a funcao novamente

imprimirDigito:
blt x12, x7, continuar						#se o valor < que a potencia de 10 pula para nao imprimir os zeros a esquerda
addi x28, x28, 48							#converte para caractere
sb x28, 1024(x0)							#imprime o digito

continuar:
addi x5, x5, 1							#incrementa o contador de digitos
jal x0, loopImprimir							#imprimir o proximo digito


end: halt


