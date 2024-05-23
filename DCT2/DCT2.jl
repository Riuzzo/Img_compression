# Definizione di una funzione
import FFTW

function saluta(nome)
    println("Ciao, $nome")
    matrix = ones(10, 10)
    FFTW.dct(matrix)
    println(FFTW.dct(matrix))
end

# Chiamata della funzione
saluta("Mondo")