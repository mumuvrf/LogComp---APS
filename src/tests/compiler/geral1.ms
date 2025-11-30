@lista := [10, 20, 30]

>> "Tamanho inicial: " + tamanho_de(@lista)

# Teste de append
@lista << 40

# Teste de acesso e modificação por índice
@lista[0] := 999
>> "Lista modificada: " + @lista

# Teste de input para variável
? "Digite um numero:"
> @x

-> Se @x > 10:
    >> "Maior que 10"
    -> Se @x > 100:
         >> "Gigante!"
-> Senao:
    >> "Pequeno ou igual a 10"

! "Fim do teste"