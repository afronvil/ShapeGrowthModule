using ShapeGrowthModule

# --- CONFIGURATION DE LA DimENSION ---
# Changez ceci à 2 pour 2D, à 3 pour 3D
const Dim = 2 
# ------------------------------------

# Ces fonctions doivent être définies AVANT d'être passées à set_max_function!
fct7(cell::Cell) = round(5*sin(cell.coordinates[1])) + 5
fct8(cell::Cell) = 30
fct9(cell::Cell) = round(5 * sin(cell.coordinates[1])) + 5

xml_file_path = "xml/cellTypes130.xml"
cell_type_sequence=[7, 8, 9, 7]
num_steps = 55

cell_data = load_cell_data(xml_file_path, cell_type_sequence)

# --- GÉNÉRALISATION DE LA CRÉATION DES CELLULES ET DE LA TAILLE DE LA GRILLE ---

# Définir la position d'origine des cellules initiales en fonction de la Dimension
initial_cell_origin = if Dim == 2
    [50, 50]
elseif Dim == 3
    [50, 50, 5]
else
    error("Unsupported dimension: $(Dim). Use 2 or 3.")
end


# Définir la taille de la grille en fonction de la Dimension
grid_size = if Dim == 2
    [100, 100]
elseif Dim == 3
    [100, 100, 10]
else
    error("Unsupported dimension: $(Dim). Use 2 or 3.")
end

my_initial_stromal_dict = nothing      

my_initial_cells_dict = create_default_initial_cells_dict(
    initial_cell_origin, 
    cell_type_sequence[1])


# CORRECTION: L'instanciation de CellModel n'utilise plus de paramètre de type {Dim}.
# CORRECTION: Le dictionnaire stromal utilise maintenant les types Vector{Int64} et StromalCell standard.
model = CellModel(
    initial_cells_dict = my_initial_cells_dict,
    cell_data = cell_data,
    cell_type_sequence = cell_type_sequence,
    grid_size = grid_size,
    initial_stromal_cells_dict = Dict{Vector{Int64}, StromalCell}()
)


# Définition des fonctions de calcul de max_divisions pour chaque type de cellule
set_max_function!(model, 7, fct7)
set_max_function!(model, 8, fct8)
set_max_function!(model, 9, fct9)


println("Start simulation...")
# Exécution de la simulation
run!(model, num_steps)
println("Simulation complete.")


# Visualisation des résultats
visualization(model)
println("Script execution completed.")