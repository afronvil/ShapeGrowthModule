using ShapeGrowthModels # Ensure your module is correctly loaded

fct1(cell::ShapeGrowthModels.Cell) = ShapeGrowthModels.fibonacci(2) + 2 # F(2) = 1, donc 1 + 2 = 3
fct2(cell::ShapeGrowthModels.Cell) = ShapeGrowthModels.fibonacci(3) + 2 # F(3) = 2, donc 2 + 2 = 4
fct3(cell::ShapeGrowthModels.Cell) = ShapeGrowthModels.fibonacci(4) + 2 # F(4) = 3, donc 3 + 2 = 5
fct4(cell::ShapeGrowthModels.Cell) = ShapeGrowthModels.fibonacci(5) + 2 # F(5) = 5, donc 5 + 2 = 7
fct5(cell::ShapeGrowthModels.Cell) = ShapeGrowthModels.fibonacci(6) + 2 # F(6) = 8, donc 8 + 2 = 10

num_steps = 200
xml_file="../xml/cellTypes130.xml"
cell_type_sequence=[2, 3, 4, 5, 2, 3,  4, 5,2, 3,  4, 5,2, 3,  4, 5,2, 3,  4, 5]#1, 2, 1, 3, 1, 4, 5, 1, 2, 3, 4, 5] # Séquence de types incluant 5

# # Initial cells - a small central group
# initial_cells_dict = Dict{Tuple{Int64, Int64}, ShapeGrowthModels.Cell}()
# first_type = cell_type_sequence[1]
# for i in -2:2, j in -2:2
#     coords = (50 + i, 50 + j)
#     initial_cells_dict[coords] = ShapeGrowthModels.Cell(coords, 0, first_type, first_type, 0, 0, 0, true, false, 1)
# end
# initial_cells = ShapeGrowthModels.CellSetByCoordinates(initial_cells_dict)
initial_cells = ShapeGrowthModels.create_default_initial_cells((50, 50), cell_type_sequence[1])

# CellModel
model = ShapeGrowthModels.CellModel(initial_cells; xml_file=xml_file, cell_type_sequence=cell_type_sequence)

# Définition des fonctions de division maximale pour chaque type de cellule
ShapeGrowthModels.set_max_function!(model, 1, fct1)
ShapeGrowthModels.set_max_function!(model, 2, fct2)
ShapeGrowthModels.set_max_function!(model, 3, fct3)
ShapeGrowthModels.set_max_function!(model, 4, fct4)
ShapeGrowthModels.set_max_function!(model, 5, fct5)

# Exécution de la simulation
ShapeGrowthModels.run!(model)

# Visualisation des résultats
script_name = splitext(basename(@__FILE__))[1]
output_directory = "../expl/"
filename = joinpath(output_directory, "fibonacci_flower_$(script_name).gif")

ShapeGrowthModels.visualize(model,filename)