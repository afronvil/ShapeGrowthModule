using ShapeGrowthModule


model = CellModel(
    cell_type_sequence = [:W, :N, :E, :W, :U] ,
    grid_size = [100, 100, 100],
)
# ------------------------------------

#max_cell_divisions = model.cell_data[cell_type]["directions"]

Dim=length(model.grid_size)
println("Dimension of the model: ", Dim)


initial_cell_origin = middle(model.grid_size)
initial_cells_dict = create_default_initial_cells_dict(initial_cell_origin, model.cell_type_sequence[1])
model.tissue_cells = initial_cells_dict

# Définition des fonctions de calcul de max_cell_divisions pour chaque type de cellule
set_max_function!(model, :W, cell -> 20)
set_max_function!(model, :E, cell -> 20)
set_max_function!(model, :N, cell -> 40)
set_max_function!(model, :U, cell -> round(Int, 5 * sin(6/10*cell.coordinates[1])+5 * sin(6/10*cell.coordinates[2])) + 5)

set_cell_data(model)

println("Start simulation...")
# Exécution de la simulation en utilisant l'argument mot-clé
run!(model, num_steps=80)
println("Simulation complete.")

# Visualisation des résultats
visualization(model)
println("Script execution completed.")
