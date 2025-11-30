# Programa: Verificador de Números Primos
# Objetivo: Teste de carga aritmética e lógica booleana estrita.

@numero := 0
@divisor := 2
@eh_primo := Verdadeiro

? "Digite um número inteiro positivo para verificar primariedade:"
> @numero

-> Se @numero <= 1:
    @eh_primo := Falso
    >> "Números menores ou iguais a 1 não são primos."
-> Senao:
    # Otimização matemática: verificar até a raiz quadrada (simulada)
    # Loop de divisão
    Enquanto (@divisor * @divisor) <= @numero:
        
        # Operador Módulo (%) testando resto da divisão
        -> Se (@numero % @divisor) == 0:
            @eh_primo := Falso
            # Forçamos a saída do loop tornando a condição do Enquanto falsa
            @divisor := @numero 
        
        @divisor := @divisor + 1

# Saída
-> Se @eh_primo == Verdadeiro:
    ! "O número " + @numero + " É PRIMO."
-> Senao:
    ! "O número " + @numero + " NÃO É PRIMO."
