using ShapeGrowthModels

xml_file = "../xml/cellTypes.xml"
max_div_sequence = [4, 10, 6, 6] 
cell_type_sequence = [1, 2, 3, 1]

num_steps = 25
grid_size = (100, 100)
# --- Chargement des données des cellules ---
cell_data = ShapeGrowthModels.load_cell_data(xml_file, cell_type_sequence)


# --- Lancement de la simulation ---
history, step = ShapeGrowthModels.run_simulation(ShapeGrowthModels.initial_cells, num_steps, grid_size, cell_type_sequence; cell_data, max_div_sequence = max_div_sequence)
    
#ShapeGrowthModels.visualize_cells(history[step], step, grid_size, cell_data)
ShapeGrowthModels.visualize_history(history, grid_size, cell_data)


function get_generated_form(cell_type_sequence::Vector{Int64};max_div_sequence::Vector{Int64}= Int64[])
    history, step=ShapeGrowthModels.run_simulation(ShapeGrowthModels.initial_cells, num_steps, grid_size, cell_type_sequence; xml_file = xml_file, max_div_sequence, toto=toto)
    #ShapeGrowthModels.visualize_cells(history[step], step, grid_size, cell_data)
    ShapeGrowthModels.visualize_history(history, grid_size, cell_data)
end

function get_generated_form(cell_type_sequence::Vector{Int64}, toto::Bool = false)
    max_div_sequence = Int64[] # Initialiser avec le bon type
    history, step = ShapeGrowthModels.run_simulation(ShapeGrowthModels.initial_cells, num_steps, grid_size, cell_type_sequence; cell_data, max_div_sequence = max_div_sequence, toto = toto)
    #ShapeGrowthModels.visualize_cells(history[step], step, grid_size, cell_data)
    ShapeGrowthModels.visualize_history(history, grid_size, cell_data)
end

#get_generated_form(cell_type_sequence; max_div_sequence)

get_generated_form(cell_type_sequence, true)