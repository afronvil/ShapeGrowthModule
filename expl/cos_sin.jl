using ShapeGrowthModels # Assurez-vous que votre module est correctement chargé
using Random # Pour une meilleure gestion de l'aléatoire

# Nombre de fonctions fct à générer
num_fct = 10

# Génération automatique du vecteur de fonctions fct utilisant cos et sin
fct = [function(cell::ShapeGrowthModels.Cell)
           amplitude = 5.0
           frequence = 0.5
           phase = (i - 1) * pi / (num_fct / 2) # Déphasage pour chaque fonction
           return round(amplitude * (sin(frequence * cell.coordinates[1] + phase) + cos(frequence * cell.coordinates[2] - phase)) + amplitude + 2)
       end for i in 1:num_fct]

num_steps = 100
xml_file="../xml/cellTypes130.xml"



# Générer la séquence des types de cellules aléatoirement entre 1 et 130
cell_type_sequence = ShapeGrowthModels.generate_cell_type_sequence()

# Initial cells
initial_cells = ShapeGrowthModels.create_default_initial_cells((50, 50), cell_type_sequence[1])

# CellModel
model = ShapeGrowthModels.CellModel(initial_cells; xml_file=xml_file, cell_type_sequence=cell_type_sequence)

# Définition des fonctions de division maximale pour chaque type de cellule
for i in 1:length(fct)
    ShapeGrowthModels.set_max_function!(model, i, fct[i])
end

# Exécution de la simulation
ShapeGrowthModels.run!(model)

# Visualisation des résultats
script_name = splitext(basename(@__FILE__))[1]
output_directory = "../expl/"
filename = joinpath(output_directory, "auto_trig_fct_$(script_name).gif")

ShapeGrowthModels.visualize(model,filename)