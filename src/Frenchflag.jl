
using ColorSchemes
using Plots


max_div_sequence = [4, 10, 6, 6] 
cell_types_sequence = [1, 2, 3, 1]

include("struct_cell_env.jl")
include("initialization.jl")





# --- Lancement de la simulation ---
run_simulation(initial_cells, num_steps, grid_size, cell_types_sequence; xml_file,max_div_sequence)

