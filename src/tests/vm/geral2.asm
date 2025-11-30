; Arquivo gerado pelo compilador Maiêutic
; Fonte: ../tests/compiler/geral2.ms

PUSH_NUM 42
STORE @inteiro
PUSH_NUM 3.14
STORE @float
PUSH_STR "Texto com espaços e símbolos!"
STORE @string
PUSH_BOOL 0
STORE @bool
BUILD_LIST 0
STORE @lista_vazia
PUSH_NUM 1
PUSH_STR "Dois"
PUSH_BOOL 1
BUILD_LIST 3
STORE @lista_mista
LOAD @lista_mista
PUSH_NUM 1
INDEX
STORE @item
PUSH_NUM 100
APPEND @lista_vazia
LOAD @inteiro
PUSH_NUM 2
MUL
APPEND @lista_vazia
LOAD @inteiro
PUSH_NUM 10
PUSH_NUM 2
MUL
ADD
STORE @calculo
LOAD @inteiro
PUSH_NUM 10
ADD
PUSH_NUM 2
MUL
STORE @parenteses
PUSH_NUM 5
PUSH_NUM 2
CMP_GT
PUSH_NUM 10
PUSH_NUM 11
CMP_NEQ
AND
LOAD @bool
PUSH_BOOL 1
CMP_EQ
OR
STORE @teste_logico
PUSH_STR "Início do teste de fluxo. Digite 1:"
QUESTION
INPUT @input_user
LOAD @input_user
PUSH_NUM 1
CMP_EQ
JUMP_IF_FALSE L_else_0
PUSH_STR "Nível 1 OK"
PRINT
PUSH_NUM 0
STORE @contador
LABEL L_while_1
LOAD @contador
PUSH_NUM 2
CMP_LT
JUMP_IF_FALSE L_end_while_1
PUSH_STR "  Nível 2 (Loop): "
LOAD @contador
ADD
PRINT
LOAD @contador
PUSH_NUM 1
CMP_EQ
JUMP_IF_FALSE L_end_if_2
PUSH_STR "    Nível 3 (Branch interno)"
PRINT
LABEL L_end_if_2
LOAD @contador
PUSH_NUM 1
ADD
STORE @contador
JUMP L_while_1
LABEL L_end_while_1
JUMP L_end_if_0
LABEL L_else_0
PUSH_STR "Erro no teste de fluxo."
PRINT_CONCL
LABEL L_end_if_0
LOAD @lista_mista
LEN
STORE @tamanho
PUSH_STR "Teste finalizado. Tamanho da lista: "
LOAD @tamanho
ADD
PRINT_CONCL

HALT
