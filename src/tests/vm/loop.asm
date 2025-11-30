; Arquivo gerado pelo compilador Maiêutic
; Fonte: ../tests/compiler/loop.ms

PUSH_NUM 1
STORE @i
PUSH_STR "Digite um número inteiro N (>= 1):"
QUESTION
INPUT @n
LABEL L_while_0
LOAD @i
LOAD @n
CMP_LTE
JUMP_IF_FALSE L_end_while_0
PUSH_STR "i = "
LOAD @i
ADD
PRINT
LOAD @i
PUSH_NUM 1
ADD
STORE @i
JUMP L_while_0
LABEL L_end_while_0
PUSH_STR "Fim do loop."
PRINT_CONCL

HALT
