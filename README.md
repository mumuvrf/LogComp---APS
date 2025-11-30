# LogComp---APS
Repositório dedicado ao desenvolvimento da Atividade Prática Supersivionada, cujo objetivo é a criação de uma linguagem de programação, da disciplina de Lógica da Computação do Insper.

**Aluno:** Vinícius Rodrigues de Freitas


## Linguagem proposta

Uma linguagem de programação com o objetivo de elaborar um roteiro de aprendizado pleno a partir da aplicação do Método Socrático, especificamente a **Maiêutica**, no âmbito do autoestudo.

A ideia é que seja útil em múltiplas interfaces, seja código, papel ou até mesmo a própria mente do usuário.

## Maiêutica

A maiêutica de Sócrates é um método filosófico que faz parte do chamado "método socrático". A palavra vem do grego maieutiké, que significa "arte de partejar". Sócrates usava essa metáfora porque dizia que, assim como sua mãe ajudava mulheres a dar à luz crianças, ele ajudava as pessoas a "dar à luz ideias".

O processo consiste em fazer perguntas sucessivas, de modo a levar a pessoa a refletir sobre o que pensa, identificar contradições, abandonar certezas mal fundamentadas e, aos poucos, construir um conhecimento mais sólido e consciente. Sócrates acreditava que ninguém deveria simplesmente "receber respostas prontas", mas sim ser levado a descobrir por si mesmo.

Na prática pessoal, a maiêutica pode ser aplicada como um exercício de autoquestionamento. Por exemplo:

```
Em vez de apenas aceitar uma ideia, a pessoa pode perguntar a si mesma: O que exatamente eu quero dizer com isso?

Depois: Por que acredito nisso?

Em seguida: Existe algum exemplo que confirme ou contradiga essa ideia?

Por fim: Essa explicação faz sentido de forma consistente?
```

## Estrutura EBNF

### Gramática

```
(* ========================================== *)
(*      GRAMÁTICA DA LINGUAGEM MAIEUTIC       *)
(* ========================================== *)

(* --- Estrutura Macro --- *)
Program            = { Statement } ;
Block              = Indent , { Statement } , Dedent ;

Statement          = Assignment
                   | Question
                   | InputAnswer
                   | Conditional
                   | Loop
                   | Output
                   | Conclusion
                   | Comment ;

Comment            = "#" , { AllChars - NewLine } ;

(* --- Gerenciamento de Memória (LValues) --- *)
Identifier         = Letter , { Letter | Digit | "_" } ;
Variable           = "@" , Identifier ;

(* Definição de Listas e Acesso *)
List               = "[" , [ Expression , { "," , Expression } ] , "]" ;
ListAccess         = Variable , "[" , Expression , "]" ;

(* LValue: Onde podemos gravar dados (Variável ou Posição de Lista) *)
LValue             = Variable | ListAccess ;

(* --- Atribuição e Modificação --- *)
(* := substitui o valor. << adiciona ao final (apenas para listas) *)
AssignmentOperator = ":=" | "<<" ;

Assignment         = LValue , AssignmentOperator , Expression ;


(* --- Expressões e Matemática --- *)
Expression         = LogicExpr ;

LogicExpr          = CompExpr , { ("AND" | "OR") , CompExpr } ;
CompExpr           = MathExpr , [ ("==" | "!=" | ">" | "<" | ">=" | "<=") , MathExpr ] ;

MathExpr           = Term , { ("+" | "-") , Term } ;
Term               = Factor , { ("*" | "/" | "%") , Factor } ;

Factor             = "(" , Expression , ")"
                   | Number
                   | String
                   | Boolean
                   | List
                   | ListAccess   (* Leitura de valor *)
                   | Variable     (* Leitura de valor *)
                   | LengthFunc ;

LengthFunc         = "tamanho_de(" , (Variable | List) , ")" ;


(* --- Fluxo Socrático --- *)
Question           = "?" , Expression ; 
InputAnswer        = ">" , LValue ; (* Resposta vai para uma LValue *)  
Output             = ">>" , Expression ;
Conclusion         = "!" , Expression ;


(* --- Controle de Fluxo --- *)
Conditional        = "->" , "Se" , Expression , ":" , Block 
                   , [ "->" , "Senao" , ":" , Block ] ;

Loop               = "Enquanto" , Expression , ":" , Block ;


(* --- Primitivos Léxicos --- *)
Boolean            = "Verdadeiro" | "Falso" ;
Number             = Digit , { Digit } , [ "." , { Digit } ] ;
String             = '"' , { AllChars - '"' } , '"' ;

(* Indentação é tratada pelo Lexer, gerando tokens INDENT/DEDENT *)
Indent             = ? TOKEN_INDENT ? ;
Dedent             = ? TOKEN_DEDENT ? ;
```

### Explicação dos elementos

- **Program** → é o roteiro de execução lógica, contendo a sequência de perguntas, operações de memória e estruturas de decisão.

- **Variables (@)** → representam o estado do conhecimento (memória). Armazenam definições, contadores ou listas de argumentos que podem ser consultados e alterados.

- **Assignment (:=)** e **Append (<<)** → são operações de modificação do pensamento. `:=` define ou redefine uma premissa, enquanto `<<` adiciona um novo elemento a uma lista de ideias existentes.

- **Question (?)** → inicia uma etapa de investigação, apresentando uma dúvida ou problema.

- **Input Answer (>)** → captura a resposta do interlocutor e a armazena em uma variável para ser validada ou processada logicamente.

- **Log (>>)** → exibe um pensamento intermediário, contexto ou feedback do sistema, sem exigir uma resposta imediata.

- **Branch (-> Se ...)** → representa a bifurcação do raciocínio baseada em lógica booleana. Define caminhos diferentes dependendo da consistência das respostas (Verdadeiro ou Falso).

- **Loop (Enquanto ... :)** → estrutura de repetição analítica. Mantém o ciclo de questionamento ativo até que uma condição específica (como a eliminação da dúvida) seja satisfeita.

- **Conclusion (!)** → marca uma síntese final ou uma formulação madura alcançada após o processamento lógico.

### Exemplos

**Descobrindo a definição de felicidade**

```
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
```

**Verificador de números primos**

```
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
```