using Shape_Growth_Populate
using Plots # S'assurer que Plots est chargé

# --- CONFIGURATION DE LA DimENSION ---
const Dim = 2 # Changez ceci à 2 pour 2D, à 3 pour 3D
# ------------------------------------

# Ces fonctions doivent être définies AVANT d'être passées à set_max_function!
fct7(cell::Shape_Growth_Populate.Cell) = round(15*sin(cell.coordinates[1])) + 5
fct8(cell::Shape_Growth_Populate.Cell) = 50
fct9(cell::Shape_Growth_Populate.Cell) = round( 15 * sin(cell.coordinates[1])) + 5
fct128(cell::Shape_Growth_Populate.Cell) = 50
fct129(cell::Shape_Growth_Populate.Cell) = 50
fct130(cell::Shape_Growth_Populate.Cell) = 50
fct131(cell::Shape_Growth_Populate.Cell) = 50
xml_file="xml/cellTypes130.xml"
cell_type_sequence=[128, 129]#,122,126]#7, 8, 9, 7]#128,
num_steps = 20
dist_cellule_fibroblast = 5.0

# --- GÉNÉRALISATION DE LA CRÉATION DES CELLULES ET DE LA TAILLE DE LA GRILLE ---

# Définir la position d'origine des cellules initiales en fonction de la Dimension
initial_cell_origin = if Dim == 2
    (50, 50)
elseif Dim == 3
    (50, 50, 5)
else
    error("Dimension non supportée: $(Dim). Utilisez 2 ou 3.")
end

initial_stromal_cell_origin = if Dim == 2
    (50, 50)
elseif Dim == 3
    (50, 50, 5)
else
    error("Dimension non supportée: $(Dim). Utilisez 2 ou 3.")
end

# Définir la taille de la grille en fonction de la Dimension
grid_size = if Dim == 2
    (100, 100)
elseif Dim == 3
    (100, 100, 10)
else
    error("Dimension non supportée: $(Dim). Utilisez 2 ou 3.")
end

const DEFAULT_STROMAL_CELL_TYPE = 99 

my_initial_cells_dict = Shape_Growth_Populate.create_default_initial_cells_dict(
    Val(Dim), 
    initial_cell_origin, 
    cell_type_sequence[1])

my_initial_stromal_dict = Shape_Growth_Populate.create_default_initial_stromal_cells_dict(
    Val(Dim),
    initial_stromal_cell_origin,
    cell_type_sequence[1]
)


model = Shape_Growth_Populate.CellModel{Dim}(
    initial_cells_dict = my_initial_cells_dict, # This should still be a CellSetByCoordinates
    initial_stromal_cells_dict = my_initial_stromal_dict,
    xml_file = xml_file,
    cell_type_sequence = cell_type_sequence,
    grid_size = grid_size
)




# Définition des fonctions de calcul de max_divisions pour chaque type de cellule
Shape_Growth_Populate.set_max_function!(model, 7, fct7)
Shape_Growth_Populate.set_max_function!(model, 8, fct8)
Shape_Growth_Populate.set_max_function!(model, 9, fct9)
Shape_Growth_Populate.set_max_function!(model, 128, fct128)
Shape_Growth_Populate.set_max_function!(model, 129, fct129)
Shape_Growth_Populate.set_max_function!(model, 130, fct130)



println("Démarrage de la simulation...")
# Exécution de la simulation
Shape_Growth_Populate.run!(model, num_steps=num_steps) # Nombre d'étapes augmenté pour une meilleure visibilité
println("Simulation terminée.")


# Visualisation des résultats
Shape_Growth_Populate.visualization(model)
println("Exécution du script terminée.")







