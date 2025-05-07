
using ColorSchemes
using Plots
include("struct_cell_env.jl")
include("initialization.jl")
# --- Initialisation et paramètres ---
#cell_types_sequence = [4,2,1]
#max_div_sequence = [5, 10, 5, 5] 
cell_types_sequence = [1, 2, 3, 1]



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

