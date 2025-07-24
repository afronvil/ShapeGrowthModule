# ~/Nextcloud/Logiciels/ShapeGrowthModule/src/utils.jl

# ... (vos fonctions utilitaires existantes) ...


"""
    generate_multi_indices(Dim::Int, max_degree::Int)

Génère tous les multi-indices `alpha` = (α1, ..., α_Dim) tels que sum(α_i) <= max_degree.
"""
function generate_multi_indices(Dim::Int, max_degree::Int)
    indices = NTuple{Dim, Int}[]
    function _generate(current_index::Vector{Int}, current_sum::Int, k::Int)
        if k == Dim
            current_index[k] = max_degree - current_sum
            if current_index[k] >= 0
                push!(indices, NTuple{Dim, Int}(current_index))
            end
            return
        end
        for i in 0:(max_degree - current_sum)
            current_index[k] = i
            _generate(current_index, current_sum + i, k + 1)
        end
    end

    all_indices_set = Set{NTuple{Dim, Int}}()
    for total_degree in 0:max_degree
        temp_index = zeros(Int, Dim)
        _generate(temp_index, 0, 1) # This populates 'indices'
        # Now filter 'indices' to only include those that sum to 'total_degree'
        for idx in indices
            if sum(idx) == total_degree
                push!(all_indices_set, idx)
            end
        end
    end
    
    return collect(all_indices_set) # Retourne un Vector d'éléments uniques et triés
end


"""
    generate_multi_indices(Dim::Int, max_degree::Int)

Génère tous les multi-indices `alpha` = (α1, ..., α_Dim) tels que sum(α_i) <= max_degree.
"""
function generate_multi_indices_unique(Dim::Int, max_degree::Int)
    indices = NTuple{Dim, Int}[]
    # Fonction récursive pour générer les indices
    function _generate(current_index::Vector{Int}, current_sum::Int, k::Int)
        if k == Dim
            # Le dernier élément est déterminé par la somme restante
            current_index[k] = max_degree - current_sum
            if current_index[k] >= 0
                push!(indices, NTuple{Dim, Int}(current_index))
            end
            return
        end

        for i in 0:(max_degree - current_sum)
            current_index[k] = i
            _generate(current_index, current_sum + i, k + 1)
        end
    end

    for total_degree in 0:max_degree
        _generate(zeros(Int, Dim), 0, 1) # Appel initial pour chaque degré total
    end
    
    # Filter out duplicates that might occur due to the `max_degree - current_sum` logic
    # and ensure sum(alpha_i) <= max_degree
    unique_indices = Set{NTuple{Dim, Int}}()
    for idx in indices
        if sum(idx) <= max_degree
            push!(unique_indices, idx)
        end
    end
    return collect(unique_indices) # Retourne un Vector d'éléments uniques
end

"""
    calculate_spatial_moments(cells::Dict{NTuple{Dim, Int64}, Cell{Dim}}, max_degree::Int; filter_cell_type::Union{Int64, Nothing}=nothing) where Dim

Calcule les moments spatiaux de la distribution cellulaire jusqu'à un degré maximal donné.
Peut optionnellement filtrer les cellules par un type donné.

# Arguments
- `cells::Dict{NTuple{Dim, Int64}, Cell{Dim}}`: Dictionnaire des cellules (par ex., model.cells ou model.history[end].cells).
- `max_degree::Int`: Le degré maximal (somme des exposants) des moments à calculer.
- `filter_cell_type::Union{Int64, Nothing}`: Si non `nothing`, seuls les moments des cellules de ce type seront calculés.

# Retourne
- `Dict{NTuple{Dim, Int64}, Float64}`: Un dictionnaire où les clés sont les multi-indices
  (NTuple{Dim, Int64}) et les valeurs sont les moments calculés (Float64).
"""
function calculate_spatial_moments_type(cells::Dict{NTuple{Dim, Int64}, Cell{Dim}}, max_degree::Int; filter_cell_type::Union{Int64, Nothing}=nothing) where Dim
    moments = Dict{NTuple{Dim, Int64}, Float64}()

    multi_indices = generate_multi_indices(Dim, max_degree)

    for alpha in multi_indices
        moments[alpha] = 0.0
    end

    for (coords, cell) in cells
        if cell.is_alive # Ne considérer que les cellules vivantes
            # Filtrer par type de cellule si un filtre est spécifié
            if filter_cell_type === nothing || cell.cell_type == filter_cell_type
                for alpha in multi_indices
                    term = 1.0
                    for i in 1:Dim
                        term *= (Float64(coords[i]))^alpha[i]
                    end
                    moments[alpha] += term
                end
            end
        end
    end

    return moments
end

"""
    calculate_spatial_moments(cells::Dict{NTuple{Dim, Int64}, Cell{Dim}}, max_degree::Int) where Dim

Calcule les moments spatiaux de la distribution cellulaire jusqu'à un degré maximal donné.
Le moment d'ordre alpha = (α1, ..., α_Dim) est la somme de (x1^α1 * x2^α2 * ... * x_Dim^α_Dim)
pour toutes les cellules présentes.

# Arguments
- `cells::Dict{NTuple{Dim, Int64}, Cell{Dim}}`: Dictionnaire des cellules (par ex., model.cells ou model.history[end].cells).
- `max_degree::Int`: Le degré maximal (somme des exposants) des moments à calculer.

# Retourne
- `Dict{NTuple{Dim, Int64}, Float64}`: Un dictionnaire où les clés sont les multi-indices
  (NTuple{Dim, Int64}) et les valeurs sont les moments calculés (Float64).
"""
function calculate_spatial_moments(cells::Dict{NTuple{Dim, Int64}, Cell{Dim}}, max_degree::Int) where Dim
    moments = Dict{NTuple{Dim, Int64}, Float64}()

    # Générer tous les multi-indices possibles jusqu'au degré maximal
    multi_indices = generate_multi_indices(Dim, max_degree)

    # Initialiser tous les moments à zéro
    for alpha in multi_indices
        moments[alpha] = 0.0
    end

    # Calculer la somme pour chaque moment
    for (coords, cell) in cells
        if cell.is_alive # Ne considérer que les cellules vivantes
            for alpha in multi_indices
                term = 1.0
                for i in 1:Dim
                    term *= (Float64(coords[i]))^alpha[i]
                end
                moments[alpha] += term
            end
        end
    end

    return moments
end
