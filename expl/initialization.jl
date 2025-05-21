include("../src/functions.jl")
include("../src/data_xml.jl")
include("../src/visualization_xml.jl")
include("../src/struct_cell_env.jl")
# --- Initialisation et paramètres ---

#max_cell_division = 6
xml_file = "../xml/cellTypes.xml"
num_steps = 25
grid_size = (100, 100)
cell_data = load_cell_data(xml_file, cell_type_sequence)
#max_div_sequence = [4, 10, 6, 6] 
#cell_types_sequence = [1, 5, 2, 3, 2, 1]
#cell_types_sequence = [4]

cases = Dict(
    1 => [(0, -1)], #Ouest
    2 => [(-1, 0)], #Nord
    3 => [(0, 1)],  #Est
    4 => [(1, 0)],  #Sud
    # 5 => [(1, -1)], #Sud-Ouest
    # 6 => [(-1, -1)],#Nord-Ouest
    # 7 => [(1, 1)], #Sud-Est
    # 8 => [(-1, 1)],#Nord-Est
)

# --- Initial cell configuration ---
initial_cells = CellSetByCoordinates(Dict(
    (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))) =>
        Cell(
            (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))),
            0,
            cell_types_sequence[1],
            cell_types_sequence[1],  # initial_cell_type
            cell_types_sequence[1],
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

function calculate_max_divisions_type1(cell::Cell)::Int64
    x, y = cell.coordinates
    return round((x*y)/30) # Exemple : Dépend de la division entière de x par 10
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