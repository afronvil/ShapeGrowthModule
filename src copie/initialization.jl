include("functions.jl")

include("data_xml.jl")
include("visualization_xml.jl")

include("struct_cell_env.jl")
# --- Initialisation et paramètres ---



# --- Initialisation et paramètres ---

xml_file = "cellTypes.xml"

num_steps = 25
grid_size = (30, 30)
#max_cell_division = 6


max_div_sequence = [4, 10, 6, 6] 
cell_types_sequence = [1, 2, 3, 1]

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
