# src/functions_max.jl
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

"""
    euclidean_distance(coords1::Vector{Int64}, coords2::Vector{Int64})::Float64

Calculate the Euclidean distance between two n-dimensional points.
"""
function euclidean_distance(coords1::Vector{Int64}, coords2::Vector{Int64})
    sum_sq_diff = 0.0
    for i in 1:Dim
        sum_sq_diff += (coords1[i] - coords2[i])^2
    end
    return sqrt(sum_sq_diff)
end

function angle(coords::Vector{Int64}; center::Vector{Int64} = [50, 50, 0])
    dx = coords[1] - center[1]
    dy = coords[2] - center[2]
    # dz = coords[3] - center[3]
    return atan(dy, dx)
end

function distance_from_center(coords::Vector{Int64}; center::Vector{Int64} = [50, 50, 0])
    dx = coords[1] - center[1]
    dy = coords[2] - center[2]
    dz = coords[3] - center[3]
    return sqrt(dx^2 + dy^2 + dz^2)
end

function generate_cell_type_sequence()
    append!(cell_type_sequence, rand(1:max_type, num_elements))
    println("Random vector generated for cell_type_sequence : ", cell_type_sequence)
    return cell_type_sequence
end

# Fonction pour générer automatiquement une fonction fct_i
function generate_fct_fibonacci(i::Int)
    return function(cell)
        return fibonacci(i + 1)
    end
end

function generate_cell_type_sequence(num_elements::Int, max_type::Int)
    append!(cell_type_sequence, rand(1:max_type, num_elements))
    println("Random vector generated for cell_type_sequence : ", cell_type_sequence)
    return cell_type_sequence
end

function calculate_max_cell_divisions(model::CellModel, cell::Cell) # Pas besoin de Dim ici
    if haskey(model.max_cell_division_functions, cell.cell_type)
        val = model.max_cell_division_functions[cell.cell_type](cell)
        
        if isa(val, Int)
            return val
        elseif isa(val, AbstractString)
            return parse(Int, val)
        else
            error("La fonction max_cell_division_functions doit retourner un Int ou un String convertible en Int. Type reçu : $(typeof(val))")
        end
    else
        return 1
    end
end

function set_max_function!(model::CellModel, cell_type::Symbol, fct::Function)
    if !haskey(model.max_cell_division_functions, cell_type)
        model.max_cell_division_functions[cell_type] = fct
    else
        error("The maximum division function for cell type $cell_type is already defined.")
    end
    
end

 
function set_type_sequence!(model::CellModel, type_sequence::Vector{Int64})
    if hasfield(typeof(model), :cell_type_sequence)
        model.cell_type_sequence = type_sequence
        
    else
        error("The template does not contain a :cell_type_sequence field to store the type sequence.")
    end
end