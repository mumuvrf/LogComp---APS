; Arquivo gerado pelo compilador Maiêutic
; Fonte: ../tests/compiler/geral1.ms

PUSH_NUM 10
PUSH_NUM 20
PUSH_NUM 30
BUILD_LIST 3
STORE @lista
PUSH_STR "Tamanho inicial: "
LOAD @lista
LEN
ADD
PRINT
PUSH_NUM 40
APPEND @lista
PUSH_NUM 0
PUSH_NUM 999
STORE_INDEX @lista
PUSH_STR "Lista modificada: "
LOAD @lista
ADD
PRINT
PUSH_STR "Digite um numero:"
QUESTION
INPUT @x
LOAD @x
PUSH_NUM 10
CMP_GT
JUMP_IF_FALSE L_else_0
PUSH_STR "Maior que 10"
PRINT
LOAD @x
PUSH_NUM 100
CMP_GT
JUMP_IF_FALSE L_end_if_1
PUSH_STR "Gigante!"
PRINT
LABEL L_end_if_1
JUMP L_end_if_0
LABEL L_else_0
PUSH_STR "Pequeno ou igual a 10"
PRINT
LABEL L_end_if_0
PUSH_STR "Fim do teste"
PRINT_CONCL

HALT
