# LogComp---APS
Repositório dedicado ao desenvolvimento da Atividade Prática Supersivionada, cujo objetivo é a criação de uma linguagem de programação, da disciplina de Lógica da Computação do Insper.


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
Program        = { Statement } ;

Statement      = Question | Answer | SubQuestion | Branch | Conclusion | Loop ;

Question       = "?" , Text ;
SubQuestion    = "??" , Text ;
Answer         = ">" , Text ;
Branch         = "->" , "Se" , Condition , ":" , { Statement } ;
Conclusion     = "!" , Text ;

Loop           = EnquantoLoop | RepetirLoop ;

EnquantoLoop   = "Enquanto" , Condition , ":" , { Statement } ;
RepetirLoop    = "Repetir" , Text , "vezes:" , { Statement } ;

Condition      = Text ;

Text           = { Character } ;
Character      = ? qualquer caractere exceto quebra de linha ? ;

```

### Explicação dos elementos

- **Program** → é o conjunto de perguntas, respostas e ramificações (como um diário de aprendizado).

- **Question (?)** → inicia a investigação.

- **SubQuestion (??)** → surge de uma resposta anterior, aprofundando.

- **Answer (>)** → uma tentativa de resposta provisória.

- **Branch (-> Se ...)** → representa caminhos diferentes de raciocínio.

- **Loop (Enquanto ...: | Repetir ... vezes:)** → representa o uso de repetição de perguntas para aprofundamento do raciocínio.

- **Conclusion (!)** → marca uma síntese, mesmo que temporária.

### Exemplo

```
? O que é justiça?
> "Dar a cada um o que é seu."
Enquanto sentir_incerteza == True:
    ?? Isso vale para todos os casos?
    > "Talvez não, depende das circunstâncias."
    ?? Então o que é 'seu'?
    > "O que lhe é devido, mas o que é devido?"
    -> Se não há resposta consistente:
         > sentir_incerteza = True
    -> Se a definição parece coerente:
         > sentir_incerteza = False
! Cheguei a uma formulação mais madura (ainda provisória).
```