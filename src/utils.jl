# src/utils.jl

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

function generate_and_sample(num_types::Int)
    # Create a vector of random integers for cell types
    vecteur_aleatoire = rand(1:num_types, 10)
    println("Random vector generated for cell_type_sequence : ", vecteur_aleatoire)
    return vecteur_aleatoire
end



# Fonctions d'initialisation et de logique
function middle(grid_size::Vector{Int64})
    return round.(Int64, grid_size ./ 2)
end

function add_initial_cell(model::CellModel, coordinates::Vector{Int64}, initial_type::Int64)
    model.cells[coordinates] = Cell(
        coordinates,
        0,
        initial_type,
        initial_type,
        initial_type,
        0,
        0,
        true,
        false,
        1,
    )
end

# --- Fonctions pour la création de cellules initiales ---
function create_default_initial_cells_dict(initial_cell_origin::Vector{Int64}, initial_type::Symbol)
    initial_cell = Cell(
        coordinates=initial_cell_origin,
        timer=0,
        cell_type=initial_type,
        initial_cell_type=initial_type,
        last_division_type=initial_type,
        nbdiv=0,
        max_cell_divisions=5,
        is_alive=true,
        has_proliferated_this_step=false,
        current_type_index_in_sequence=1,
    )
    cells_dict = Dict(initial_cell_origin => initial_cell)
    return cells_dict
end

function create_default_initial_stromal_cells_dict(initial_stromal_cell_origin::Vector{Int64}, initial_stromal_type::Int64)
    initial_stromal_cell = StromalCell(
        coordinates=initial_stromal_cell_origin,
        timer=0,
        cell_type=initial_stromal_type,
        initial_stromal_cell_type=initial_stromal_type,
        last_division_type=0,
        nbdiv=0,
        max_divisions=0,
        is_alive=true,
        has_proliferated_this_step=false
    )
    stromal_cells = Dict(initial_stromal_cell_origin => initial_stromal_cell)
    println("Initial stromal cells created at $(initial_stromal_cell_origin) with type $(initial_stromal_type).")
    return stromal_cells
end

# Fonction utilitaire pour créer un ensemble compact de cellules
# IMPORTANT: Le type de retour est changé de Cell à Cell
function create_compact_cells(origin::Vector{Int64},  cell_statut::Symbol,cell_type::Symbol, radius::Int64)
    cells_dict = Dict{Vector{Int64}, Cell}()
    Dim = length(origin)
    # Générer toutes les coordonnées dans un cube englobant
    for offset in Iterators.product(( -radius:radius for _ in 1:Dim )...)
        coord = origin .+ collect(offset)
        # Vérifier si la coordonnée est dans la sphère de rayon 'radius'
        if sum((coord .- origin).^2) <= radius^2
            new_cell = Cell(
                coordinates=coord,
                timer=0,
                cell_statut=cell_statut,
                cell_type=cell_type,
                initial_cell_type=cell_type,
                last_division_type=cell_type,
                nbdiv=0,
                max_cell_divisions=5,
                is_alive=true,
                has_proliferated_this_step=false,
                current_type_index_in_sequence=1,
            )
            cells_dict[coord] = new_cell
        end
    end
    return cells_dict
end