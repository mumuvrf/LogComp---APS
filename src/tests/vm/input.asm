; Arquivo gerado pelo compilador Maiêutic
; Fonte: ../tests/compiler/input.ms

PUSH_STR "Qual o seu nome?"
QUESTION
INPUT @nome
PUSH_STR "Olá, "
LOAD @nome
ADD
PRINT
PUSH_STR "Fim do teste de input."
PRINT_CONCL

HALT
