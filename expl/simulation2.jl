using ShapeGrowthModels

xml_file = "cellTypes.xml"

cell_type_sequence = [1, 2, 3, 1]
initial_cells = ShapeGrowthModels.create_default_initial_cells()
num_steps = 50

grid_size = (100, 100)
xml_file = "cellTypes.xml" # Assurez-vous que ce fichier existe et est accessible


# --- Chargement des données des cellules ---

cell_data = ShapeGrowthModels.load_cell_data(xml_file, cell_type_sequence)
history, step = ShapeGrowthModels.cellular_dynamics(
    initial_cells, num_steps, grid_size, cell_type_sequence,xml_file
    )
# --- Lancement de la simulation ---
#    
#ShapeGrowthModels.visualize_cells(history[step], step, grid_size, cell_data)
ShapeGrowthModels.visualize_history(history, grid_size, cell_data)

