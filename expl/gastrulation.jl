using ShapeGrowthModule


model = CellModel(
    cell_type_sequence = [:SE,:A] ,
    grid_size = [100,100],#,100],
)
# ------------------------------------

#max_cell_divisions = model.cell_data[cell_type]["directions"]

Dim=length(model.grid_size)
println("Dimension of the model: ", Dim)


initial_cell_origin = middle(model.grid_size)
initial_cells_dict = create_default_initial_cells_dict(initial_cell_origin, model.cell_type_sequence[1])
model.tissue_cells = initial_cells_dict

# Définition des fonctions de calcul de max_cell_divisions pour chaque type de cellule
set_max_function!(model, :SE, cell -> 50)
set_max_function!(model, :A, cell -> 10)#round(Int, 5 * sin(cell.coordinates[1])+5 * sin(cell.coordinates[2])) + 5)

set_cell_data(model)

println("Start simulation...")
# Exécution de la simulation en utilisant l'argument mot-clé
run!(model, num_steps=10)
println("Simulation complete.")

# Visualisation des résultats
visualization(model)
println("Script execution completed.")
