
function calculate_spatial_moments_type(cells::Dict{NTuple{Dim, Int64}, Cell{Dim}}, max_degree::Int; filter_cell_type::Union{Symbol, Nothing}=nothing) where Dim
    moments = Dict{NTuple{Dim, Int64}, Float64}()

    multi_indices = generate_multi_indices(Dim, max_degree)

    for alpha in multi_indices
        moments[alpha] = 0.0
    end

    for (coords, cell) in cells
        if cell.is_alive # Ne considérer que les cellules vivantes
            # Filtrer par type de cellule si un filtre est spécifié
            if filter_cell_type === nothing || String(cell.cell_type) == filter_cell_type
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
