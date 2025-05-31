function fibonacci(n)
    if n <= 1
        return n
    else
        a, b = 0, 1
        for _ in 2:n
            a, b = b, a + b
        end
        return b
    end
end

function angle(coords::Tuple{Int64, Int64}; center::Tuple{Int64, Int64} = (50, 50))
    dx = coords[1] - center[1]
    dy = coords[2] - center[2]
    return atan(dy, dx)
end

function distance_from_center(coords::Tuple{Int64, Int64}; center::Tuple{Int64, Int64} = (50, 50))
    dx = coords[1] - center[1]
    dy = coords[2] - center[2]
    return sqrt(dx^2 + dy^2)
end

function generate_cell_type_sequence()
    # Créer un vecteur d'entiers aléatoires de longueur 10 entre 1 et 130 (inclus)
    cell_type_sequence = rand(1:130, 10)
    println("Vecteur aléatoire généré pour cell_type_sequence : ", cell_type_sequence)
    return cell_type_sequence
end

# Fonction pour générer automatiquement une fonction fct_i
function generate_fct_fibonacci(i::Int)
    return function(cell::ShapeGrowthModels.Cell)
        return ShapeGrowthModels.fibonacci(i + 1) + 2
    end
end