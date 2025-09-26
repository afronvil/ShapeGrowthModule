using ShapeGrowthModule
xml_file_path = "xml/cellTypes130.xml"

model = CellModel(
    cell_type_sequence = [:W_Q, :N_Q, :E_Q, :W_Q  ] ,
    grid_size = [100, 100, 100],
)
# ------------------------------------
set_cell_data(model, xml_file_path)

Dim=length(model.grid_size)
println("Dimension of the model: ", Dim)


initial_cell_origin = middle(model.grid_size)
initial_cells_dict = create_default_initial_cells_dict(initial_cell_origin, model.cell_type_sequence[1])
model.cells = initial_cells_dict

# Définition des fonctions de calcul de max_cell_divisions pour chaque type de cellule
set_max_function!(model, :W_Q, cell -> round(Int, 5 * sin(cell.coordinates[1])) + 5)
set_max_function!(model, :N_Q, cell -> 30)
set_max_function!(model, :E_Q, cell -> round(Int, 5 * sin(cell.coordinates[1])) + 5)

println(model.max_cell_division_functions[:W_Q])
println("Start simulation...")
# Exécution de la simulation en utilisant l'argument mot-clé
run!(model, num_steps=50)
println("Simulation complete.")

# Visualisation des résultats
visualization(model)
println("Script execution completed.")
