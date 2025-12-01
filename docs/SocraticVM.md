# SocraticVM – Máquina Virtual da Linguagem Maiêutic

Este documento descreve a **SocraticVM**, máquina virtual responsável por executar o código assembly gerado pelo compilador da linguagem **Maiêutic**.

O arquivo principal da VM é [`src/vm/socraticvm.py`], e esta documentação deve ser mantida em `/docs`.

---

## 1. Papel da SocraticVM no projeto

Pipeline de compilação e execução da linguagem:

1. **Fonte Maiêutic** (`.ms`)  
   Escrito na linguagem de alto nível (perguntas, respostas, loops, etc).

2. **Compilador em C++** (`lexer.l`, `parser.y`, `ast.h`)  
   - Faz análise léxica, sintática e constrói uma AST.  
   - Gera um arquivo de **assembly da Maiêutic** (`.asm`) usando os métodos `generate(...)` da AST.

3. **SocraticVM (Python)** (`socraticvm.py`)  
   - Carrega o `.asm`;  
   - Resolve labels;  
   - Executa instruções sequencialmente em uma **máquina de pilha**.

---

## 2. Como executar a VM

Uso básico na linha de comando:

```bash
python3 socraticvm.py programa.asm
````

Para acompanhar a execução passo a passo (trace das instruções):

```bash
python3 socraticvm.py programa.asm --trace
```

Parâmetros:

* `programa.asm` – arquivo assembly gerado pelo compilador.
* `--trace` (opcional) – imprime em `stderr` cada instrução antes de executá-la, no formato:

  ```text
  [PC=12] ADD
  [PC=13] STORE @x
  ...
  ```

---

## 3. Arquitetura da SocraticVM

### 3.1 Componentes principais

* **Pilha de avaliação** – `stackVM: List[Value]`
  Usada para todas as operações aritméticas, lógicas, de listas e para passagem de argumentos entre instruções.

* **Memória de variáveis globais** – `variables: Dict[str, Value]`

  * Chave: nome textual da variável, por exemplo `@x`, `@historico_erros`.
  * Valor: objeto `Value` com tipo dinâmico.

* **Tabela de labels** – `labels: Dict[str, int]`
  Mapeia `LABEL <nome>` para o índice da instrução correspondente no vetor de programa (endereço de salto).

* **Programa** – `List[Instruction]`
  Cada `Instruction` possui:

  ```python
  @dataclass
  class Instruction:
      op: str       # nome da operação, ex: "PUSH_NUM", "ADD"
      args: List[str]  # argumentos em texto
  ```

* **Contador de programa (PC)**
  Índice da instrução atual dentro da lista `program`. Controlado explicitamente pelas instruções de salto (`JUMP`, `JUMP_IF_FALSE`).

* **Registradores auxiliares**

  * `reg0`, `reg1`: registradores gerais usados por instruções de movimento:

    * `MOV_TOP_R0`, `MOV_TOP_R1`, `PUSH_R0`, `PUSH_R1`.

* **Sensores**
  Estado para instruções que leem o ambiente:

  * `start_time` (para o sensor `time`),
  * gerador pseudo-aleatório (`random.Random`) para `rand`.

---

## 4. Sistema de tipos em tempo de execução

A VM trabalha com um tipo dinâmico `Value`:

```python
class ValueType:
    NIL = "NIL"
    BOOL = "BOOL"
    NUMBER = "NUMBER"
    STRING = "STRING"
    LIST = "LIST"
```

Cada valor possui:

* `type` – um dos tipos acima;
* `bool_val`, `num_val`, `str_val`, `list_val`.

Construtores auxiliares:

* `Value.nil()` – valor nulo (`Nulo`);
* `Value.from_bool(b)`;
* `Value.from_num(n)`;
* `Value.from_str(s)`;
* `Value.from_list(list_of_values)`.

### 4.1 Representação textual (`to_string`)

Usada para `PRINT`, `PRINT_CONCL` e `QUESTION`:

* **BOOL**

  * `True` → `"Verdadeiro"`
  * `False` → `"Falso"`

* **NUMBER**

  * Impresso em formato decimal com precisão controlada (`"{:.15g}"`).

* **STRING**

  * Impresso exatamente como armazenado.

* **LIST**

  * `"[]"` para lista vazia
  * `[elem1, elem2, ...]` concatenando `to_string` de cada elemento.

* **NIL**

  * `"Nulo"`.

---

## 5. Formato do arquivo `.asm`

### 5.1 Estrutura geral

* Arquivo texto UTF-8.
* Cada linha contém **uma única instrução** ou um **label** ou **comentário**.
* Linhas vazias são ignoradas.

Exemplos:

```asm
; Comentário: programa gerado pelo compilador
PUSH_NUM 10
STORE @x
LABEL L_while_0
LOAD @x
PUSH_NUM 0
CMP_GT
JUMP_IF_FALSE L_end_while_0
...
LABEL L_end_while_0
HALT
```

### 5.2 Comentários

* Linhas que começam com `;` são ignoradas pela VM:

  ```asm
  ; isto é um comentário
  ```

### 5.3 Labels

* Declaração:

  ```asm
  LABEL <nome>
  ```
* Não vira uma instrução executável; apenas registra o endereço (índice na lista de `Instruction`) na tabela `labels`.
* Usado por `JUMP` e `JUMP_IF_FALSE`.

### 5.4 Literais de string

Instruções de string usam `PUSH_STR`:

```asm
PUSH_STR "Texto com \"aspas\" e \\barra"
```

A VM:

1. Localiza o primeiro e o último `"`.
2. Remove as aspas externas.
3. Trata `\"` e `\\` como escapes.

O compilador C++ é responsável por escapar adequadamente as aspas e barras ao gerar o `.asm`.

---

## 6. Instruções da SocraticVM

A seguir, as instruções disponíveis, organizadas por categoria. Todas usam a **pilha** como principal mecanismo de passagem de valores.

> Em caso de falta de elementos na pilha, a VM imprime uma mensagem de erro e pode encerrar a execução daquela operação.

### 6.1 Instruções de pilha e valores imediatos

| Instrução                   | Efeito                                         |                                                   |
| --------------------------- | ---------------------------------------------- | ------------------------------------------------- |
| `PUSH_NUM <n>`              | Empilha número de ponto flutuante `n`.         |                                                   |
| `PUSH_BOOL <0               | 1>`                                            | Empilha booleano (`0` → Falso, `1` → Verdadeiro). |
| `PUSH_STR "<texto>"`        | Empilha string literal.                        |                                                   |
| `PUSH_NIL`                  | Empilha valor `Nulo`.                          |                                                   |
| `MOV_TOP_R0` / `MOV_TOP_R1` | Faz `reg0/reg1 = pop()`.                       |                                                   |
| `PUSH_R0` / `PUSH_R1`       | Empilha o valor armazenado em `reg0` / `reg1`. |                                                   |

### 6.2 Variáveis globais

| Instrução            | Efeito                                                                                   |
| -------------------- | ---------------------------------------------------------------------------------------- |
| `LOAD <nome>`        | Empilha o valor de `variables[nome]` ou `Nulo` se a variável não existir.                |
| `STORE <nome>`       | `variables[nome] = pop()`.                                                               |
| `APPEND <nome>`      | Pega `v = pop()`. Garante que `variables[nome]` seja uma lista, e adiciona `v` ao final. |
| `STORE_INDEX <nome>` | Espera na pilha: topo = valor, logo abaixo = índice numérico. Atualiza posição de lista. |

Detalhes de `STORE_INDEX`:

* Ordem na pilha **antes** da instrução:

  * topo: **valor**;
  * logo abaixo: **índice** (NUMBER);
* Se `variables[nome]` não for lista, a VM reporta erro:

  * `[VM] STORE_INDEX em variável não-lista: <nome>`.

### 6.3 Listas

| Instrução      | Efeito                                                                                               |
| -------------- | ---------------------------------------------------------------------------------------------------- |
| `BUILD_LIST n` | Desempilha `n` valores (o último desempilhado vira o último da lista), constrói uma lista e empilha. |
| `INDEX`        | Espera na pilha: topo = índice, abaixo = lista; empilha o elemento `lista[indice]`.                  |

Tratamento de erros:

* Se aplicado em não-lista → mensagem e empilha `Nulo`.
* Se índice fora do intervalo → mensagem e empilha `Nulo`.

### 6.4 Aritmética

Todas operam sobre dois operandos no topo da pilha: primeiro é o segundo `pop()` (operando esquerdo), segundo é o primeiro `pop()` (operando direito).

| Instrução | Semântica                                   |
| --------- | ------------------------------------------- |
| `ADD`     | Soma numérica ou concatenação de strings.   |
| `SUB`     | Subtração numérica.                         |
| `MUL`     | Multiplicação numérica.                     |
| `DIV`     | Divisão numérica (divide por zero → log/0). |
| `MOD`     | Resto de divisão (`math.fmod`).             |

Regras de `ADD`:

* Se qualquer operando for STRING → concatena `a.to_string() + b.to_string()`.
* Caso contrário → soma numérica.

### 6.5 Comparação

| Instrução | Semântica principal                                                                 |
| --------- | ----------------------------------------------------------------------------------- |
| `CMP_EQ`  | Igualdade: números com tolerância (`1e-9`), demais com comparação de `to_string()`. |
| `CMP_NEQ` | Diferente: negação da igualdade acima.                                              |
| `CMP_LT`  | `<` numérico.                                                                       |
| `CMP_LTE` | `<=` numérico.                                                                      |
| `CMP_GT`  | `>` numérico.                                                                       |
| `CMP_GTE` | `>=` numérico.                                                                      |

Todas **consomem** 2 valores e **empilham** um `BOOL`.

### 6.6 Lógica booleana e verdade

| Instrução | Semântica                       |
| --------- | ------------------------------- |
| `AND`     | `is_truthy(a) AND is_truthy(b)` |
| `OR`      | `is_truthy(a) OR is_truthy(b)`  |

A função `is_truthy` considera:

* **BOOL** → seu valor;
* **NUMBER** → `num_val != 0.0`;
* **STRING** → verdadeira se não vazia **e** diferente de `"Falso"` e `"Nao"`;
* **LIST** → verdadeira se não vazia;
* **NIL** → sempre falsa.

### 6.7 Comprimento (`LEN`)

| Instrução | Efeito                                                                                 |
| --------- | -------------------------------------------------------------------------------------- |
| `LEN`     | Consome 1 valor. Se for LIST → tamanho da lista. Se STRING → comprimento. Senão → `0`. |

Empilha um `NUMBER` com o tamanho.

### 6.8 Controle de fluxo

| Instrução               | Efeito                                                                                              |
| ----------------------- | --------------------------------------------------------------------------------------------------- |
| `JUMP <label>`          | Define `PC = labels[label]`.                                                                        |
| `JUMP_IF_FALSE <label>` | Consome um valor da pilha; se `not is_truthy(valor)`, salta para `label`, senão segue para próxima. |
| `HALT`                  | Encerra a execução do programa.                                                                     |

Labels são declarados com:

```asm
LABEL <nome>
```

e nunca são "executados".

### 6.9 Entrada/Saída (interface socrática)

Essas instruções representam a “interface dialógica” da linguagem.

| Instrução     | Efeito de alto nível                                      |
| ------------- | --------------------------------------------------------- |
| `QUESTION`    | Consome 1 valor e imprime: `[?] <valor>` em `stdout`.     |
| `PRINT`       | Consome 1 valor e imprime: `>> <valor>` em `stdout`.      |
| `PRINT_CONCL` | Consome 1 valor e imprime: `! <valor>` em `stdout`.       |
| `INPUT <var>` | Lê uma linha do usuário e armazena em `variables[<var>]`. |

#### Semântica de `INPUT`

* Prompt: `"> "` (como na linguagem `>`).
* Se `EOF` → variável recebe `Nulo`.
* Se linha vazia → variável recebe `Nulo`.
* Caso contrário:

  1. Tenta converter para `float`.
     Se a string parece ser um número, armazena como `NUMBER`.
  2. Se não for número:

     * `"Verdadeiro"` ou `"Sim"` → `BOOL True`;
     * `"Falso"` ou `"Nao"` → `BOOL False`;
     * qualquer outra coisa → `STRING`.

---

## 7. Sensores

A instrução `READ_SENSOR <nome>` permite ler valores “externos” úteis para scripts:

| Sensor | Semântica                                                                |
| ------ | ------------------------------------------------------------------------ |
| `time` | Número de segundos (float) desde o início da execução do programa na VM. |
| `rand` | Número real pseudo-aleatório uniforme em `[0, 1)`.                       |

Qualquer sensor desconhecido:

* Imprime: `[VM] Sensor desconhecido: <nome>`;
* Empilha `Nulo`.

Exemplo de uso:

```asm
READ_SENSOR time     ; empilha delta de tempo
STORE @t_decorrido

READ_SENSOR rand     ; empilha número aleatório
STORE @sorteio
```

---

## 8. Erros em tempo de execução

A SocraticVM não lança exceções Python para o usuário; em vez disso, imprime mensagens em `stderr` ou `stdout` (dependendo do contexto) e tenta continuar quando possível.

Erros típicos:

* Pilha com elementos insuficientes:

  * `[VM] Erro: pilha com menos de N elementos`
* `STORE_INDEX` em variável que não é lista:

  * `[VM] STORE_INDEX em variável não-lista: @nome`
* Índice fora de faixa em `INDEX` / `STORE_INDEX`:

  * `[VM] INDEX índice fora do intervalo`
  * `[VM] STORE_INDEX índice fora do intervalo`
* Operação de pilha inválida (`pop` em pilha vazia):

  * `[VM] Erro: pop em pilha vazia`
* Label não encontrado em `JUMP` / `JUMP_IF_FALSE`:

  * `[VM] Label não encontrado: L_algum`

Esses logs são importantes para depurar o compilador e o assembly gerado.

---

## 9. Exemplo de mapeamento Maiêutic → Assembly (ilustrativo)

Trecho em Maiêutic:

```mai
@numero := 10
>> "Contando..."
Enquanto @numero > 0:
    >> @numero
    @numero := @numero - 1
! "Fim."
```

Assembly gerado (esboço, simplificado):

```asm
; Inicialização
PUSH_NUM 10
STORE @numero

PUSH_STR "Contando..."
PRINT

; Loop
LABEL L_while_0
LOAD @numero
PUSH_NUM 0
CMP_GT
JUMP_IF_FALSE L_end_while_0

    ; corpo do loop
    LOAD @numero
    PRINT

    LOAD @numero
    PUSH_NUM 1
    SUB
    STORE @numero

JUMP L_while_0
LABEL L_end_while_0

PUSH_STR "Fim."
PRINT_CONCL

HALT
```

Esse exemplo ilustra como os construtos de alto nível definidos em `ast.h` são traduzidos sistematicamente para as instruções primitivas da SocraticVM.

---

Com esta especificação, a SocraticVM passa a ser um componente bem definido da arquitetura da linguagem Maiêutic, servindo como alvo estável para o compilador e como base para experimentos de novas construções semânticas ligadas ao método socrático.