# Compilador da Linguagem Maiêutic

Este documento descreve **como compilar e utilizar o compilador** da linguagem Maiêutic para gerar arquivos **assembly** (`.asm`) que serão executados posteriormente pela **SocraticVM**.

Arquivos principais do compilador (diretório `src/compiler`):

- `lexer.l` – analisador léxico (Flex)
- `parser.y` – analisador sintático + `main` do compilador (Bison)
- `ast.h` – definição da AST e geração de código assembly
- `Makefile` – automatiza o processo de compilação do binário `maieutic`

---

## 1. Dependências

Para compilar o compilador, é necessário ter instalados:

- `flex` – gerador de analisadores léxicos
- `bison` – gerador de analisadores sintáticos
- `g++` – compilador C++ (com suporte a C++17)
- `make` – para rodar o `Makefile`

Em sistemas baseados em Debian/Ubuntu, por exemplo:

```bash
sudo apt-get install flex bison g++ make
````

---

## 2. Compilando o compilador (`maieutic`)

No diretório onde está o `Makefile` (normalmente `src/compiler`):

```bash
make
```

O `Makefile` faz:

```make
all: maieutic

maieutic: lexer.l parser.y ast.h
	bison -d parser.y
	flex lexer.l
	g++ -std=c++17 parser.tab.c lex.yy.c -o maieutic -lm
```

Ou seja:

1. **Bison** gera `parser.tab.c` e `parser.tab.h` a partir de `parser.y`.
2. **Flex** gera `lex.yy.c` a partir de `lexer.l`.
3. **g++** compila `parser.tab.c` + `lex.yy.c` e produz o executável **`maieutic`**.

Se quiser limpar os arquivos gerados:

```bash
make clean
```

O alvo `clean` remove:

```make
clean:
	rm maieutic parser.tab.c parser.tab.h lex.yy.c
```

---

## 3. Uso do compilador

Uma vez compilado, o executável `maieutic` é o compilador da linguagem.
O `main` está definido em `parser.y` e a interface de linha de comando é:

```text
Uso: maieutic fonte.ms [saida.asm]
```

* `fonte.ms` – arquivo na linguagem Maiêutic (código-fonte de alto nível).
* `saida.asm` (opcional) – nome do arquivo assembly de saída.

### 3.1 Gerando um arquivo `.asm` com nome explícito

```bash
./maieutic programa.ms programa.asm
```

Neste caso:

* O compilador lê `programa.ms`;
* Analisa léxico/sintaticamente e constrói a AST (`Block* rootBlock`);
* Chama `rootBlock->generate(out)` para escrever as instruções de assembly;
* Escreve o resultado em `programa.asm` e adiciona um `HALT` ao final.

### 3.2 Gerando `.asm` automaticamente (troca de extensão)

Se o segundo argumento **não** for passado, o compilador cria o nome de saída a partir do arquivo fonte:

```bash
./maieutic programa.ms
```

Comportamento:

* Remove a extensão original de `programa.ms`;
* Acrescenta `.asm`, gerando `programa.asm`;
* Salva o assembly nesse arquivo.

Exemplos:

| Comando                     | Arquivo de saída gerado |
| --------------------------- | ----------------------- |
| `./maieutic roteiro.ms`     | `roteiro.asm`           |
| `./maieutic felicidade.ms`  | `felicidade.asm`        |
| `./maieutic teste.maieutic` | `teste.asm`             |

---

## 4. Fluxo completo: fonte → assembly → execução na VM

1. **Escreva o programa em Maiêutic** (por exemplo `felicidade.ms`).

2. **Compile para assembly** com o compilador:

   ```bash
   ./maieutic felicidade.ms
   # gera felicidade.asm
   ```

3. **Execute o assembly na SocraticVM**:

   ```bash
   python3 src/vm/socraticvm.py felicidade.asm
   ```

   (ou com trace:)

   ```bash
   python3 src/vm/socraticvm.py felicidade.asm --trace
   ```

---

## 5. Tratamento de erros de compilação

Durante a compilação:

* Erros léxicos (caracteres inesperados) são tratados pelo `lexer.l`.
* Erros sintáticos são reportados por `yyerror` em `parser.y`, com mensagem:

  ```text
  Erro de Sintaxe: <detalhes> na linha <n>
  ```

Se ocorrer erro de parsing:

* O assembly **não é gerado**;
* O compilador imprime:

  ```text
  Erro de sintaxe. Assembly não gerado.
  ```

---

## 6. Resumo rápido de comandos

```bash
# 1) Ir até o diretório do compilador
cd src/compiler

# 2) Compilar o compilador
make

# 3) Gerar assembly a partir de um fonte
./maieutic exemplo.ms           # gera exemplo.asm automaticamente
./maieutic exemplo.ms out.asm   # gera out.asm explicitamente

# 4) (Opcional) Limpar arquivos gerados
make clean
```