# expl/flag.jl
using ShapeGrowthModule
# --- CONFIGURATION DE LA DimENSION ---
const Dim = 2 # Changez ceci à 2 pour 2D, à 3 pour 3D
# ------------------------------------

# Ces fonctions doivent être définies AVANT d'être passées à set_max_function!
fct7(cell::Cell{Dim}) = 5
fct8(cell::Cell{Dim}) = 10
fct9(cell::Cell{Dim}) = 5

xml_file_path = "xml/cellTypes130.xml"
cell_type_sequence=[7, 8, 9, 7]
num_steps = 10
dist_cellule_fibroblast = 1000.0
cell_data = load_cell_data(xml_file_path, cell_type_sequence)
# --- GÉNÉRALISATION DE LA CRÉATION DES CELLULES ET DE LA TAILLE DE LA GRILLE ---

block_size_rows = 5
block_size_cols = 5

initial_cell_origin = if Dim == 2
    (50, 50)
elseif Dim == 3
    (50, 50, 5)
else
    error("Dimension non supportée: $(Dim). Utilisez 2 ou 3.")
end


# Définir la taille de la grille en fonction de la dimension
grid_size = if Dim == 2
    (100, 100)
elseif Dim == 3
    (100, 100, 10)
else
    error("Dimension non supportée: $(Dim). Utilisez 2 ou 3.")
end



my_initial_cells_dict = create_default_initial_cells_dict(
    Val(Dim), 
    initial_cell_origin, 
    cell_type_sequence[1])


model = CellModel{Dim}(
    initial_cells_dict = my_initial_cells_dict, # This should still be a CellSetByCoordinates
    cell_data = cell_data,
    cell_type_sequence = cell_type_sequence,
    grid_size = grid_size,
    initial_stromal_cells_dict = Dict{NTuple{Dim, Int64}, StromalCell{Dim}}()
)





# Définition des fonctions de calcul de max_divisions pour chaque type de cellule
set_max_function!(model, 7, fct7)
set_max_function!(model, 8, fct8)
set_max_function!(model, 9, fct9)

println("Démarrage de la simulation...")
# Exécution de la simulation
run!(model, num_steps=50) # Nombre d'étapes augmenté pour une meilleure visibilité
println("Simulation terminée.")


# Visualisation des résultats
visualization(model)
println("Exécution du script terminée.")
