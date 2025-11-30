# Loop simples: conta de 1 até N

@i := 1

? "Digite um número inteiro N (>= 1):"
> @n

Enquanto @i <= @n:
    >> "i = " + @i
    @i := @i + 1

! "Fim do loop."
