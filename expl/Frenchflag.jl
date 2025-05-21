
using ColorSchemes
using Plots


max_div_sequence = [4, 10, 6, 6] 
cell_type_sequence = [1, 2, 3, 1]

include("../src/struct_cell_env.jl")
include("initialization.jl")


# --- Lancement de la simulation ---
history, step = run_simulation(initial_cells, num_steps, grid_size, cell_type_sequence; cell_data, max_div_sequence = max_div_sequence)
    
visualize_cells(history[step], step, grid_size, cell_data)
