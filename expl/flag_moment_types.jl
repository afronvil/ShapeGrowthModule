# flag_moment_flag.jl
using Shape_Growth_Populate


# --- CONFIGURATION DE LA DimENSION ---
const Dim = 3# Changez ceci à 2 pour 2D, à 3 pour 3D
# ------------------------------------

# ... (vos définitions de fct7, fct8, fct9, xml_file, cell_type_sequence, etc.) ...
fct7(cell::Shape_Growth_Populate.Cell{Dim}) = 5
fct8(cell::Shape_Growth_Populate.Cell{Dim}) = 15
fct9(cell::Shape_Growth_Populate.Cell{Dim}) = 5

xml_file="xml/cellTypes130.xml"
cell_type_sequence=[7, 8, 9, 7]
num_steps_sim = 50
dist_cellule_fibroblast = 1000.0


initial_cell_origin = if Dim == 2
    (50, 50)
elseif Dim == 3
    (50, 50, 5)
else
    error("Dimension non supportée: $(Dim). Utilisez 2 ou 3.")
end

grid_size = if Dim == 2
    (100, 100)
elseif Dim == 3
    (100, 100, 10)
else
    error("Dimension non supportée: $(Dim). Utilisez 2 ou 3.")
end

my_initial_cells_dict = Shape_Growth_Populate.create_default_initial_cells_dict(
    Val(Dim), 
    initial_cell_origin, 
    cell_type_sequence[1]
)

model = Shape_Growth_Populate.CellModel{Dim}(
    initial_cells_dict = my_initial_cells_dict,
    xml_file = xml_file, 
    cell_type_sequence = cell_type_sequence,
    grid_size = grid_size, 
    initial_stromal_cells_dict = Dict{NTuple{Dim, Int64}, Shape_Growth_Populate.StromalCell{Dim}}()
)

Shape_Growth_Populate.set_max_function!(model, 7, fct7)
Shape_Growth_Populate.set_max_function!(model, 8, fct8)
Shape_Growth_Populate.set_max_function!(model, 9, fct9)

println("Démarrage de la simulation...")
Shape_Growth_Populate.run!(model, num_steps=num_steps_sim) 
println("Simulation terminée.")

# --- NOUVEAU : Calcul des moments spatiaux ---
max_moment_degree = 2 # Définissez le degré maximal des moments à calculer (ex: 0, 1 ou 2)
println("\nCalcul des moments spatiaux jusqu'au degré ", max_moment_degree, "...")
spatial_moments = Shape_Growth_Populate.calculate_spatial_moments(model.history[end].cells, max_moment_degree)

println("Moments spatiaux calculés (ordre alpha => valeur) :")
for (alpha, moment_value) in sort(collect(spatial_moments), by=x->sum(x.first))
    println("  Moment ", alpha, " : ", moment_value)
end
# ---------------------------------------------

println("\n--- Calcul des moments spatiaux par type et par étape ---")
max_moment_degree =4 # Définissez le degré maximal des moments à calculer

for (step_idx, history_entry) in enumerate(model.history)
    cells_at_step = history_entry.cells
    println("\n=== Étape de simulation: $(step_idx-1) ===") # step_idx est 1-basé, la première étape est 0

    # Moments pour toutes les cellules (type = ALL)
    all_cells_moments = Shape_Growth_Populate.calculate_spatial_moments(cells_at_step, max_moment_degree)
    println("  Moments pour TOUTES les cellules :")
    for (alpha, moment_value) in sort(collect(all_cells_moments), by=x->sum(x.first))
        println("    Moment ", alpha, " : ", moment_value)
    end

    # Moments pour chaque type de cellule spécifique
    for cell_type_id in unique(model.cell_type_sequence) # Itérer sur les types de cellules pertinents
        type_specific_moments = Shape_Growth_Populate.calculate_spatial_moments_type(cells_at_step, max_moment_degree; filter_cell_type=cell_type_id)
        println("  Moments pour le type de cellule $(cell_type_id) :")
        for (alpha, moment_value) in sort(collect(type_specific_moments), by=x->sum(x.first))
            println("    Moment ", alpha, " : ", moment_value)
        end
    end
end
println("\n--- Fin du calcul des moments ---")

# Visualisation des résultats
Shape_Growth_Populate.visualization(model)
println("Exécution du script terminée.")
