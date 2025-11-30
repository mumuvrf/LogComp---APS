; Arquivo gerado pelo compilador Maiêutic
; Fonte: ../tests/compiler/listas.ms

PUSH_STR "Maca"
PUSH_STR "Banana"
BUILD_LIST 2
STORE @frutas
PUSH_STR "Lista inicial: "
LOAD @frutas
ADD
PRINT
PUSH_STR "Laranja"
APPEND @frutas
PUSH_STR "Apos append: "
LOAD @frutas
ADD
PRINT
LOAD @frutas
LEN
STORE @qtd
PUSH_STR "Tamanho atual: "
LOAD @qtd
ADD
PRINT_CONCL
LOAD @frutas
PUSH_NUM 0
INDEX
STORE @primeira
LOAD @frutas
PUSH_NUM 2
INDEX
STORE @ultima
PUSH_STR "Primeira: "
LOAD @primeira
ADD
PRINT
PUSH_STR "Ultima: "
LOAD @ultima
ADD
PRINT
PUSH_NUM 10
PUSH_NUM 20
PUSH_NUM 30
BUILD_LIST 3
STORE @nums
LOAD @nums
PUSH_NUM 0
INDEX
LOAD @nums
PUSH_NUM 1
INDEX
ADD
LOAD @nums
PUSH_NUM 2
INDEX
ADD
STORE @soma
PUSH_STR "Soma dos elementos: "
LOAD @soma
ADD
PRINT_CONCL
PUSH_NUM 0
STORE @contador
BUILD_LIST 0
STORE @lista_dinamica
LABEL L_while_0
LOAD @contador
PUSH_NUM 3
CMP_LT
JUMP_IF_FALSE L_end_while_0
LOAD @contador
PUSH_NUM 100
MUL
APPEND @lista_dinamica
LOAD @contador
PUSH_NUM 1
ADD
STORE @contador
JUMP L_while_0
LABEL L_end_while_0
PUSH_STR "Lista gerada no loop: "
LOAD @lista_dinamica
ADD
PRINT_CONCL

HALT
