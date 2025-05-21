

using Plots
using ColorTypes


include("initialization.jl")


#max_div_sequence = 6

# # --- Lancement de la simulation ---

#run_simulation(initial_cells, num_steps, grid_size, cell_types_sequence; xml_file)
cell_type_sequence = [1, 2, 3, 1]
max_div_sequence = [5, 10, 5, 8] 

function get_generated_form(cell_type_sequence::Vector{Int64};max_div_sequence::Vector{Int64}= Int64[])
    #xml_file = "../data/cellTypes.xml"  # Vous devrez peut-être ajuster le nom du fichier XML
    num_steps = 25 # Nombre d'étapes de simulation
    grid_size = (30, 30) # Taille de la grille
    # Exécuter la simulation
    history, step=run_simulation(initial_cells, num_steps, grid_size, cell_type_sequence; xml_file = xml_file, max_div_sequence, toto=toto)
end

function get_generated_form(cell_type_sequence::Vector{Int64}, toto::Bool = false)
    max_div_sequence = Int64[] # Initialiser avec le bon type
    history, step = run_simulation(initial_cells, num_steps, grid_size, cell_type_sequence; cell_data, max_div_sequence = max_div_sequence, toto = toto)
    visualize_cells(history[step], step, grid_size, cell_data)
    #visualize_history(history, grid_size, cell_data)
end