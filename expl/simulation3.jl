using ShapeGrowthModels # Ensure your module is correctly loaded

# Utility function to create a default set of initial cells (call is redundant here if not used)
# ShapeGrowthModels.create_default_initial_cells()

# These functions must be defined BEFORE being passed to set_max_function!
fct1(cell::ShapeGrowthModels.Cell) = 5#round(10 * sin(cell.coordinates[1])) + 5
fct2(cell::ShapeGrowthModels.Cell) = 10
fct3(cell::ShapeGrowthModels.Cell) = 5#round(10 * sin(cell.coordinates[1])) + 5
fct4(cell::ShapeGrowthModels.Cell) = 5
fct5(cell::ShapeGrowthModels.Cell) = round(10 * cell.coordinates[1] * sin(cell.coordinates[1])) + 5

# --- 5. Model Initialization and Configuration ---

# Creating the model with default grid_size and xml_file
# It seems you are loading cell_data here and then overwriting the model's.
# The CellModel constructor already calls load_cell_data.
# It's likely you should rely on the constructor's loading mechanism.
# If you need to load it here for a specific reason, ensure the paths are correct.
cell_data = ShapeGrowthModels.load_cell_data("cellTypes.xml", [1, 2, 3, 1])
model = ShapeGrowthModels.CellModel()
model.cell_data = cell_data # Overwriting the cell_data loaded by the constructor

# Defining the max_divisions calculation functions for each cell type
ShapeGrowthModels.set_max_function!(model, 1, fct1)
ShapeGrowthModels.set_max_function!(model, 2, fct2)
ShapeGrowthModels.set_max_function!(model, 3, fct3)
ShapeGrowthModels.set_max_function!(model, 4, fct4)
ShapeGrowthModels.set_max_function!(model, 5, fct5)

# Defining the sequence of cell types (if needed for other parts of the model)
ShapeGrowthModels.set_type_sequence!(model, [1, 2, 3, 1])

# Running the simulation
ShapeGrowthModels.run!(model)

# Visualizing the results
ShapeGrowthModels.visualize(model)