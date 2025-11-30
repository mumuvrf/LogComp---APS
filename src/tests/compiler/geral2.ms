# TESTE DE INTEGRIDADE SINTÁTICA
# Deve exercitar: Tipos, Precedência, Nesting, Listas e I/O.

# 1. Atribuições e Tipos Primitivos
@inteiro := 42
@float   := 3.14
@string  := "Texto com espaços e símbolos!"
@bool    := Falso

# 2. Listas e Acesso
@lista_vazia := []
@lista_mista := [1, "Dois", Verdadeiro]
@item        := @lista_mista[1]  # Deve ler "Dois"

# 3. Operador Append (<<)
@lista_vazia << 100
@lista_vazia << (@inteiro * 2)

# 4. Expressões Matemáticas Complexas (Precedência)
# Esperado: 42 + (10 * 2) = 62. Se der 104, a precedência está errada.
@calculo := @inteiro + 10 * 2 
@parenteses := (@inteiro + 10) * 2

# 5. Lógica Booleana Complexa
@teste_logico := (5 > 2) AND (10 != 11) OR (@bool == Verdadeiro)

# 6. Estruturas Aninhadas (Nesting)
? "Início do teste de fluxo. Digite 1:"
> @input_user

-> Se @input_user == 1:
    >> "Nível 1 OK"
    
    # Loop Aninhado
    @contador := 0
    Enquanto @contador < 2:
        >> "  Nível 2 (Loop): " + @contador
        
        -> Se @contador == 1:
            >> "    Nível 3 (Branch interno)"
        
        @contador := @contador + 1
-> Senao:
    ! "Erro no teste de fluxo."

# 7. Funções Intrínsecas e Conclusão
@tamanho := tamanho_de(@lista_mista)
! "Teste finalizado. Tamanho da lista: " + @tamanho