using ShapeGrowthModels # Ensure your module is correctly loaded

# These functions must be defined BEFORE being passed to set_max_function!
fct7(cell::ShapeGrowthModels.Cell) = 5
fct8(cell::ShapeGrowthModels.Cell) = 10 
fct9(cell::ShapeGrowthModels.Cell) = 5 
num_steps = 25
xml_file="../xml/cellTypes130.xml"
cell_type_sequence=[7, 8, 9, 7]

initial_cells = ShapeGrowthModels.create_default_initial_cells((50, 50), cell_type_sequence[1])
model = ShapeGrowthModels.CellModel(initial_cells; xml_file=xml_file, cell_type_sequence=cell_type_sequence)

# Defining the max_divisions calculation functions for each cell type
ShapeGrowthModels.set_max_function!(model, 7, fct7)
ShapeGrowthModels.set_max_function!(model, 8, fct8)
ShapeGrowthModels.set_max_function!(model, 9, fct9)

# Running the simulation
ShapeGrowthModels.run!(model;num_steps)

# Visualizing the results
script_name = splitext(basename(@__FILE__))[1]
output_directory = "../expl/"
filename = joinpath(output_directory, "$(script_name).gif")

ShapeGrowthModels.visualize(model,filename)
