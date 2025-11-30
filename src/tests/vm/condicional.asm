; Arquivo gerado pelo compilador Maiêutic
; Fonte: ../tests/compiler/condicional.ms

PUSH_STR "Digite sua idade:"
QUESTION
INPUT @idade
LOAD @idade
PUSH_NUM 18
CMP_GTE
JUMP_IF_FALSE L_else_0
PUSH_STR "Você é maior de idade."
PRINT_CONCL
JUMP L_end_if_0
LABEL L_else_0
PUSH_STR "Você é menor de idade."
PRINT_CONCL
LABEL L_end_if_0

HALT
