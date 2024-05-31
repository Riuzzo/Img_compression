# Definizione di una funzione
using FFTW

function compute_internal_product_index(index, dimension)
    return index == 1 ? 1/sqrt(dimension) : sqrt(2/dimension)
end

function calc_b(i, y, matrix, dim)
    b = 0
    for j = 1:dim
        b += matrix[i,j] * cos(pi*(y-1)*(2*(j-1) + 1)/(2*dim))
    end
    return b
end

function dct2(matrix, x, y)
    s = compute_internal_product_index(x, size(matrix)[1])
    r = compute_internal_product_index(y, size(matrix)[1])
    temp = 0
    for i = 1:size(matrix)[1]
        b = calc_b(i, y, matrix, size(matrix)[1])
        temp += b * cos(pi*(x-1)*(2*(i-1) + 1)/(2*size(matrix)[1]))
    end
    temp *= (s*r)
    println(temp)
end

function my_dct(matrix, k)
    dim = size(matrix)[2]
    temp = 0
    for i = 1:dim
        temp += cos(pi*(k-1)*(2*(i-1) + 1)/(2*dim)) * matrix[i]
    end
    println(temp*compute_internal_product_index(k, dim))
end


for k = 1:8
    my_dct([231 32 233 161 24 71 140 245], k)
end
println("\n")
for i = 1:8
    for j = 1:8
        dct2([231 32 233 161 24 71 140 245;
        247 40 248 245 124 204 36 107;
        234 202 245 167 9 217 239 173;
        193 190 100 167 43 180 8 70;
        11 24 210 177 81 243 8 112;
        97 195 203 47 125 114 165 181;
        193 70 174 167 41 30 127 245;
        87 149 57 192 65 129 178 228], i, j)
    end
end