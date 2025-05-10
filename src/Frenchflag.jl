
using ColorSchemes
using Plots
include("struct_cell_env.jl")
include("initialization.jl")

# --- Initialisation et paramètres ---
#cell_types_sequence = [4,2,1]





# --- Lancement de la simulation ---
run_simulation(initial_cells, num_steps, grid_size, cell_types_sequence; xml_file,max_div_sequence)

