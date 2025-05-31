using ShapeGrowthModels # Assurez-vous que votre module est correctement chargé

# Fonction pour obtenir le n-ième nombre de Fibonacci (supposée exister dans ShapeGrowthModels)
# Si ce n'est pas le cas, la définition standard doit être incluse ici.

# Fonction pour générer automatiquement une fonction fct_i
function generate_fct(i::Int)
    return function(cell::ShapeGrowthModels.Cell)
        return ShapeGrowthModels.fibonacci(i + 1) + 2
    end
end

# Nombre de fonctions fct à générer
num_fct = 10

# Génération automatique du vecteur de fonctions fct
fct = [generate_fct(i) for i in 1:num_fct]

num_steps = 100
xml_file="../xml/cellTypes130.xml"

function generate_and_sample(num_types::Int)
    # Créer un vecteur d'entiers aléatoires pour les types de cellules
    vecteur_aleatoire = rand(1:num_types, 10)
    println("Vecteur aléatoire généré pour cell_type_sequence : ", vecteur_aleatoire)
    return vecteur_aleatoire
end

# Choisir le nombre de types de cellules en fonction du nombre de fonctions générées
num_cell_types = 10
cell_type_sequence = generate_and_sample(num_cell_types)

# Initial cells
initial_cells = ShapeGrowthModels.create_default_initial_cells((50, 50), cell_type_sequence[1])

# CellModel
model = ShapeGrowthModels.CellModel(initial_cells; xml_file=xml_file, cell_type_sequence=cell_type_sequence)

# Définition des fonctions de division maximale pour chaque type de cellule
for i in 1:num_cell_types
    ShapeGrowthModels.set_max_function!(model, i, fct[i])
end

# Exécution de la simulation
ShapeGrowthModels.run!(model)

# Visualisation des résultats
script_name = splitext(basename(@__FILE__))[1]
output_directory = "../expl/"
filename = joinpath(output_directory, "auto_fct_$(script_name).gif")

ShapeGrowthModels.visualize(model,filename)