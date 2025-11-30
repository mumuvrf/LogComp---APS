# Inicialização do Estado Epistemológico
@conceito  := "Felicidade"
@definicao := ""
@incerteza := Verdadeiro
@historico_erros := []  # Lista para guardar as definições descartadas

>> "Iniciando investigação sobre: " + @conceito

? "Para começar, como você define " + @conceito + " em poucas palavras?"
> @definicao

# O Ciclo Dialético (Elenchos)
Enquanto @incerteza == Verdadeiro:
    
    >> "Analisando a proposição: '" + @definicao + "'"
    
    # O Teste de Consistência (Ironia Socrática simulada)
    ? "Consegue imaginar alguém que possui isso (" + @definicao + ") mas ainda é miserável? (Sim/Não)"
    > @existe_contradicao
    
    -> Se @existe_contradicao == "Sim":
        # Momento de Aporia (O reconhecimento do erro)
        ? "O que falta a essa pessoa, mesmo tendo " + @definicao + "?"
        > @elemento_faltante
        
        # Guardamos a definição velha na lista de erros antes de mudar
        @historico_erros << @definicao
        
        >> "Interessante. Então '" + @definicao + "' é insuficiente pois ignora '" + @elemento_faltante + "'."
        
        ? "Tente uma nova definição que inclua " + @elemento_faltante + ":"
        > @definicao  # Atualizamos a variável com a nova crença (Mutabilidade)
    -> Senao:
        # Se o usuário não encontra contradição, testamos a solidez
        ? "Essa definição depende de coisas externas (sorte) ou internas (ser)? (Externas/Internas)"
        > @origem
        
        -> Se @origem == "Externas":
            >> "Se depende da sorte, pode ser perdida. Felicidade frágil não é plena."
            >> "Vamos tentar aprofundar..."
            # O loop continua, forçando o usuário a repensar  
        -> Senao:
            # Critério de parada: Definição robusta e interna
            @incerteza := Falso

# A Síntese (Maiêutica completa)
>> "Investigação encerrada."
>> "Você abandonou " + tamanho_de(@historico_erros) + " definições superficiais: " + @historico_erros

! "Sua definição madura de Felicidade é: " + @definicao