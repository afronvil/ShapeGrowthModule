using ShapeGrowthModels # Ensure your module is correctly loaded

# These functions must be defined BEFORE being passed to set_max_function!
fct1(cell::ShapeGrowthModels.Cell) = 5#round(10 * sin(cell.coordinates[1])) + 5
fct2(cell::ShapeGrowthModels.Cell) = round(5*sin(cell.coordinates[1])) + 5
fct3(cell::ShapeGrowthModels.Cell) = 30
fct4(cell::ShapeGrowthModels.Cell) = round( 5 * sin(cell.coordinates[1])) + 5
fct5(cell::ShapeGrowthModels.Cell) = round(10 * cell.coordinates[1] * sin(cell.coordinates[1])) + 5

xml_file="../xml/cellTypes130.xml"
cell_type_sequence=[2, 3, 4, 2]

# Load cell data *before* creating the model if the constructor doesn't handle it
# or if you want to modify it before passing.
# However, the CellModel constructor now loads cell_data internally.
# So this line might be redundant if the constructor handles it correctly.
# Let's keep it for now, but be aware it might be loading data twice.
initial_cells = ShapeGrowthModels.create_default_initial_cells((50, 50), cell_type_sequence[1])

#cell_data = ShapeGrowthModels.load_cell_data(xml_file, cell_type_sequence)

# IMPORTANT: Pass xml_file and cell_type_sequence as keyword arguments

model = ShapeGrowthModels.CellModel(initial_cells; xml_file=xml_file, cell_type_sequence=cell_type_sequence)

# If the CellModel constructor now loads cell_data, this line becomes redundant
# and potentially overwrites what the constructor just loaded.
# You might want to remove it if the constructor's load_cell_data is sufficient.
# model.cell_data = cell_data

# Defining the max_divisions calculation functions for each cell type
ShapeGrowthModels.set_max_function!(model, 1, fct1)
ShapeGrowthModels.set_max_function!(model, 2, fct2)
ShapeGrowthModels.set_max_function!(model, 3, fct3)
ShapeGrowthModels.set_max_function!(model, 4, fct4)
ShapeGrowthModels.set_max_function!(model, 5, fct5)

# Defining the sequence of cell types (if needed for other parts of the model)
# This is now redundant if cell_type_sequence is passed to the constructor and stored there.
# ShapeGrowthModels.set_type_sequence!(model, cell_type_sequence)

# Running the simulation
ShapeGrowthModels.run!(model)

# Visualizing the results
script_name = splitext(basename(@__FILE__))[1]
output_directory = "../expl/"
filename = joinpath(output_directory, "$(script_name).gif")

ShapeGrowthModels.visualize(model,filename)
