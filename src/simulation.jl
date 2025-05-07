using Plots
using ColorTypes

include("struct_cell_env.jl")
include("initialization.jl")

# # --- Lancement de la simulation ---

 run_simulation(initial_cells, num_steps, grid_size, cell_types_sequence; xml_file)

