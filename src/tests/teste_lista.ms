# TESTE DE LISTAS
@frutas := ["Maca", "Banana"]
>> "Lista inicial: " + @frutas

@frutas << "Laranja"
>> "Apos append: " + @frutas

@qtd := tamanho_de(@frutas)
! "Tamanho atual: " + @qtd

@primeira := @frutas[0]
@ultima := @frutas[2]
>> "Primeira: " + @primeira
>> "Ultima: " + @ultima

@nums := [10, 20, 30]
@soma := @nums[0] + @nums[1] + @nums[2]
! "Soma dos elementos: " + @soma

@contador := 0
@lista_dinamica := []

Enquanto @contador < 3 :
    @lista_dinamica << (@contador * 100)
    @contador := @contador + 1

! "Lista gerada no loop: " + @lista_dinamica