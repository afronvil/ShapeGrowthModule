using ShapeGrowthModels
# --- Initialisation et paramètres ---

#max_cell_division = 6

num_steps = 25
grid_size = (100, 100)

#max_div_sequence = [4, 10, 6, 6] 

cell_type_sequence = [1, 2, 3, 1]
cell_data = load_cell_data(xml_file, cell_type_sequence)


# --- Initial cell configuration ---
initial_cells = CellSetByCoordinates(Dict(
    (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))) =>
        Cell(
            (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))),
            0,
            cell_type_sequence[1],
            cell_type_sequence[1],  # initial_cell_type
            cell_type_sequence[1],
            0,
            0, #initial_nbdiv
            true,
            false,
            1     # current_type_index_in_sequence
        )
    ))



    function calculate_max_divisions_type1(cell::Cell)::Int64
    x, y = cell.coordinates
    return 60 # Exemple : Dépend de la division entière de x par 10
end



function calculate_max_divisions_type2(cell::Cell)::Int64
    # Autre exemple : une logique différente basée sur les coordonnées.
    x, y = cell.coordinates
    return round(10*y*tan(y))
end

function calculate_max_divisions_type3(cell::Cell)::Int64
    x, y = cell.coordinates
    return round((x*x)/30) # Exemple : Dépend de la division entière de x par 10
end

function calculate_max_divisions_type5(cell::Cell)::Int64
    x, y = cell.coordinates
    return round(10*y*sin(y)+5) # Exemple : Dépend de la division entière de x par 10
end


function create_max_cell_divisions_dict()
    max_cell_divisions = Dict{Int64, Int64}()
    # Retourne le dictionnaire résultant.
    return max_cell_divisions
end

cell_type_to_max_divisions_function = Dict{Int64,Function}(
    1 => calculate_max_divisions_type1,
    2 => calculate_max_divisions_type2,
    3 => calculate_max_divisions_type3,
    #4 => calculate_max_divisions_type4,
    5 => calculate_max_divisions_type5,
    # Ajoute d'autres associations type cellulaire => fonction.
)