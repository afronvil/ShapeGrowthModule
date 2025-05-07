
using ColorSchemes
using Plots
include("struct_cell_env.jl")
include("initialization.jl")
# --- Initialisation et paramètres ---

xml_file = "cellTypesChange.xml"

num_steps = 20
grid_size = (30, 30)
max_cell_division = 6

toto


cases = Dict(
    1 => [(0, -1)],
    2 => [(-1, 0)]
    3 => [(0, 1)],
    4 => [(0, -1)],
    5 => [(1, -1)],
    6 => [(-1, -1)],
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



# --- Lancement de la simulation ---
run_simulation(initial_cells, num_steps, grid_size, cell_types_sequence; xml_file)

