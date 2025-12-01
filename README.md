# Maiêutic – Linguagem, Compilador e Máquina Virtual (SocraticVM)

**Aluno:** Vinícius Rodrigues de Freitas

Repositório dedicado ao desenvolvimento da **Atividade Prática Supersivionada** da disciplina de **Lógica da Computação** do Insper, cujo objetivo é projetar e implementar:

- uma **linguagem de programação** inspirada na **Maiêutica de Sócrates**;
- um **compilador** (C++/Flex/Bison) que gera um assembly próprio;
- uma **máquina virtual** em Python (**SocraticVM**) que executa esse assembly.

---

## 1. Ideia da linguagem

A linguagem **Maiêutic** é pensada para escrever **roteiros de investigação e aprendizado** baseados no Método Socrático, especificamente a **Maiêutica**, com foco em autoestudo.

Em vez de apenas “dar respostas prontas”, o programa conduz uma conversa:

- faz **perguntas** sucessivas;
- armazena respostas em **variáveis**;
- testa consistência com **condicionais** e **loops**;
- constrói no final uma **conclusão**.

Exemplo simplificado:

```mai
@conceito  := "Felicidade"
@definicao := ""

>> "Iniciando investigação sobre: " + @conceito
? "Como você define " + @conceito + "?"
> @definicao

Enquanto @definicao == "":
    ? "Tente uma definição mínima:"
    > @definicao

! "Definição atual: " + @definicao
````

### Principais elementos da sintaxe

* **Variáveis**: `@nome`
* **Atribuição**: `@x := 10`
* **Append em listas**: `@lista << valor`
* **Pergunta**: `? expressao`
* **Leitura de resposta**: `> @variavel`
* **Log / mensagem intermediária**: `>> expressao`
* **Conclusão**: `! expressao`
* **Condicional**:

  ```mai
  -> Se @x > 0:
      ...
  -> Senao:
      ...
  ```
* **Loop**:

  ```mai
  Enquanto @x > 0:
      ...
  ```
* **Listas**: `[1, 2, 3]`, acesso `@lista[0]`
* **Função de tamanho**: `tamanho_de(@lista)`

A gramática completa em EBNF está documentada em `/docs`.

---

## 2. Estrutura do repositório

Visão geral (pode variar levemente conforme evolução do projeto):

```text
├── docs/                     # Documentação (linguagem, VM, etc.)
└── src/
    ├── compiler/             # Compilador em C++ (Flex/Bison)
    │   ├── lexer.l
    │   ├── parser.y
    │   ├── ast.h
    │   └── Makefile
    ├── vm/
    │   └── socraticvm.py     # Máquina virtual em Python
    ├── examples/             # Programas exemplo em Maiêutic (.ms)
    │   ├── felicidade.ms
    │   ├── navio_de_teseu.ms
    │   └── verificador_de_primos.ms
    └── tests/
        ├── compiler/         # Testes de compilação (.ms)
        │   ├── geral1.ms
        │   ├── geral2.ms
        │   ├── input.ms
        │   ├── listas.ms
        │   └── loop.ms
        ├── outputs/          # Testes de execução interpretada (entradas/saídas esperadas)
        │   ├── condicional
        │   ├── geral1
        │   ├── geral2
        │   ├── input
        │   ├── listas
        │   └── loop
        └── vm/               # Testes da VM (assembly pronto)
            ├── condicional.asm
            ├── geral1.asm
            ├── geral2.asm
            ├── input.asm
            ├── listas.asm
            └── loop.asm
```

---

## 3. Compilador da linguagem Maiêutic

O compilador é construído a partir de:

* `lexer.l` – analisador léxico (Flex)
* `parser.y` – analisador sintático + `main`
* `ast.h` – AST + geração de código assembly (`generate(std::ostream&)`)
* `Makefile` – automatiza o build

### 3.1 Dependências

Instale:

* `flex`
* `bison`
* `g++` (C++17)
* `make`

Em Debian/Ubuntu:

```bash
sudo apt-get install flex bison g++ make
```

### 3.2 Compilando o compilador

No diretório do compilador:

```bash
cd src/compiler
make
```

O `Makefile` faz:

```make
all: maieutic

maieutic: lexer.l parser.y ast.h
	bison -d parser.y
	flex lexer.l
	g++ -std=c++17 parser.tab.c lex.yy.c -o maieutic -lm

clean:
	rm maieutic parser.tab.c parser.tab.h lex.yy.c
```

Após `make`, o binário `maieutic` estará disponível em `src/compiler/`.

Para limpar arquivos gerados:

```bash
make clean
```

### 3.3 Usando o compilador

Sintaxe de uso:

```text
Uso: maieutic fonte.ms [saida.asm]
```

* `fonte.ms` – arquivo na linguagem Maiêutic.
* `saida.asm` – (opcional) nome do arquivo assembly de saída.

#### Gerando `.asm` com nome explícito

```bash
cd src/compiler
./maieutic ../../examples/felicidade.ms ../../examples/felicidade.asm
```

#### Gerando `.asm` automaticamente

Se você omitir o segundo argumento, o compilador troca a extensão do arquivo de entrada por `.asm`:

```bash
./maieutic ../../examples/felicidade.ms
# gera ../../examples/felicidade.asm
```

Regra geral:

| Comando                       | Saída gerada   |
| ----------------------------- | -------------- |
| `./maieutic programa.ms`      | `programa.asm` |
| `./maieutic roteiro.maieutic` | `roteiro.asm`  |
| `./maieutic fonte.ms out.asm` | `out.asm`      |

### 3.4 Erros de compilação

Erros sintáticos são reportados com linha:

```text
Erro de Sintaxe: <detalhes> na linha <n>
Erro de sintaxe. Assembly não gerado.
```

Em caso de erro, o arquivo `.asm` **não** é criado.

---

## 4. SocraticVM – Máquina Virtual

A **SocraticVM** é uma **máquina de pilha** em Python que executa o assembly gerado pelo compilador.

Arquivo principal: `src/vm/socraticvm.py`.

### 4.1 Como executar um programa `.asm`

```bash
cd src/vm
python3 socraticvm.py caminho/para/programa.asm
```

Para ver o “trace” das instruções:

```bash
python3 socraticvm.py caminho/para/programa.asm --trace
```

### 4.2 Visão rápida da arquitetura

* **Pilha de execução** (`stackVM`) – onde as operações aritméticas, lógicas e de listas são feitas.
* **Memória de variáveis** (`variables`) – dicionário nome → valor (`Value`).
* **Tipos de valor**:

  * `NIL`, `BOOL`, `NUMBER`, `STRING`, `LIST`.
* **Labels** (`LABEL nome`) – marcadores de posição para saltos (`JUMP`, `JUMP_IF_FALSE`).
* **Registradores auxiliares** (`reg0`, `reg1`).
* **Sensores**:

  * `READ_SENSOR time` – segundos desde o início do programa;
  * `READ_SENSOR rand` – número aleatório em `[0, 1)`.

### 4.3 Instruções principais (resumo)

* **Pilhas e literais**: `PUSH_NUM`, `PUSH_BOOL`, `PUSH_STR`, `PUSH_NIL`.
* **Variáveis**: `LOAD`, `STORE`, `APPEND`, `STORE_INDEX`.
* **Listas**: `BUILD_LIST`, `INDEX`.
* **Aritmética**: `ADD`, `SUB`, `MUL`, `DIV`, `MOD`.
* **Comparações**: `CMP_EQ`, `CMP_NEQ`, `CMP_LT`, `CMP_LTE`, `CMP_GT`, `CMP_GTE`.
* **Lógica**: `AND`, `OR`, `LEN`.
* **Controle de fluxo**: `JUMP`, `JUMP_IF_FALSE`, `LABEL`, `HALT`.
* **I/O “socrático”**:

  * `QUESTION` → imprime `[?] mensagem`
  * `PRINT` → imprime `>> mensagem`
  * `PRINT_CONCL` → imprime `! mensagem`
  * `INPUT <var>` → lê do usuário e converte para número, booleano ou string.

Uma especificação mais detalhada da VM está em `/docs`.

---

## 5. Fluxo completo: do código Maiêutic à execução

1. **Escreva o programa** em `.ms`, por exemplo:

   ```mai
   # arquivo: exemplos/verificador_de_primos.ms
   ...
   ```

2. **Compile para assembly**:

   ```bash
   cd src/compiler
   ./maieutic ../../examples/verificador_de_primos.ms
   # gera ../../examples/verificador_de_primos.asm
   ```

3. **Execute o assembly** na SocraticVM:

   ```bash
   cd ../vm
   python3 socraticvm.py ../../examples/verificador_de_primos.asm
   ```

4. (Opcional) debug com `--trace` para inspecionar passo a passo:

   ```bash
   python3 socraticvm.py ../../examples/verificador_de_primos.asm --trace
   ```

---

## 6. Exemplos de programas

No diretório `examples/` há roteiros Maiêutic prontos, como:

* `felicidade.ms` – investigação sobre o conceito de felicidade;
* `navio_de_teseu.ms` – reflexão sobre identidade e mudança;
* `verificador_de_primos.ms` – exemplo aritmético lógico (verificar números primos).

Use-os para:

* entender a sintaxe;
* testar o compilador + VM;
* servir de base para novos roteiros.

Exemplo de compilação + execução de um exemplo:

```bash
cd src/compiler
./maieutic ../../examples/felicidade.ms

cd ../vm
python3 socraticvm.py ../../examples/felicidade.asm
```

---

## 7. Testes do compilador e da VM

### 7.1 Testes do compilador

No diretório `tests/compiler/`:

* Arquivos de entrada Maiêutic:
  `geral1.ms`, `geral2.ms`, `input.ms`, `listas.ms`, `loop.ms`, etc.
* Diretório `outputs/` com assemblies **esperados** para alguns testes.

Fluxo típico de teste manual:

```bash
cd src/compiler

# compila o fonte de teste
./maieutic ../../tests/compiler/geral1.ms ../../outputs/geral1_novo.asm

# compara o assembly gerado com o esperado
diff ../../tests/compiler/outputs/geral1.asm ../../outputs/geral1_novo.asm
```

Se o `diff` não mostrar diferenças, o compilador está gerando o assembly esperado.

### 7.2 Testes da VM

A validação da execução é feita combinando dois diretórios:

* `src/tests/vm/` – contém os programas em assembly já prontos para teste:
  `condicional.asm`, `geral1.asm`, `geral2.asm`, `input.asm`, `listas.asm`, `loop.asm`, etc.
* `src/tests/outputs/` – contém arquivos texto (`condicional`, `geral1`, `geral2`, `input`, `listas`, `loop`, …) com a **especificação de entrada e a saída esperada** para cada caso de teste.

Para rodar um teste da VM:

```bash
cd src/vm
python3 socraticvm.py ../../src/tests/vm/geral1.asm
```

Em seguida, compare o diálogo produzido pela VM (perguntas, respostas, logs, conclusões) com o conteúdo do arquivo correspondente em `src/tests/outputs/geral1`, que descreve quais entradas fornecer e qual saída é esperada para o teste `geral1`.

---

## 8. Próximos passos / contribuições

Algumas possibilidades de evolução:

* Adicionar novas construções de linguagem (funções, módulos, etc.).
* Refatorar e expandir os testes automatizados (tanto do compilador quanto da VM).
* Extender a SocraticVM com novas instruções e sensores.
* Escrever mais roteiros exemplo explorando outros temas filosóficos ou de estudo.