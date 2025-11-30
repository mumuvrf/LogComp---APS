# Programa: O Paradoxo do Navio de Teseu
# Objetivo: Testar mutabilidade de listas e branching baseado em input qualitativo.

@pecas_originais := ["Mastro", "Casco", "Velas", "Remos"]
@pecas_novas := []
@identidade_preservada := Verdadeiro
@indice := 0

>> "Este é o Navio de Teseu: " + @pecas_originais

# Loop de substituição
Enquanto (@indice < tamanho_de(@pecas_originais)) AND (@identidade_preservada == Verdadeiro):
    
    @peca_atual := @pecas_originais[@indice]
    
    >> "A madeira de '" + @peca_atual + "' apodreceu e foi trocada por alumínio."
    
    # Manipulação de Memória: Append na nova lista
    @pecas_novas << "Alumínio"
    
    ? "O objeto ainda é, essencialmente, o Navio de Teseu? (Sim/Não)"
    > @resposta_usuario
    
    -> Se @resposta_usuario == "Não":
        @identidade_preservada := Falso
        ! "A identidade se perdeu na troca de: " + @peca_atual
    
    @indice := @indice + 1

# Conclusão baseada no estado final da memória
-> Se @identidade_preservada == Verdadeiro:
    >> "Trocamos todas as peças."
    ! "Conclusão Fascinante: A matéria mudou (" + @pecas_novas + "), mas a essência permaneceu."
