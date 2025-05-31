using ShapeGrowthModels # Assurez-vous que votre module est correctement chargé

# Fonction pour obtenir le n-ième nombre de Fibonacci (supposée exister dans ShapeGrowthModels)
# Si ce n'est pas le cas, la définition standard doit être incluse ici.



# Nombre de fonctions fct à générer (10 éléments)
num_fct = 10

# Génération automatique du vecteur de fonctions fct
fct = [ShapeGrowthModels.generate_fct_fibonacci(i) for i in 1:num_fct]

num_steps = 100
xml_file="../xml/cellTypes130.xml"


# Générer la séquence des types de cellules aléatoirement entre 1 et 130
cell_type_sequence = [41, 109, 39, 55, 69, 7, 27, 13, 11, 75]


# Initial cells
initial_cells = ShapeGrowthModels.create_default_initial_cells((50, 50), cell_type_sequence[1])

# CellModel
model = ShapeGrowthModels.CellModel(initial_cells; xml_file=xml_file, cell_type_sequence=cell_type_sequence)

# Définition des fonctions de division maximale pour chaque type de cellule
# Nous n'avons que 10 fonctions fct, donc on mappe les 10 premiers types de cellules.
for i in 1:min(length(fct), maximum(cell_type_sequence))
    if i <= length(fct)
        ShapeGrowthModels.set_max_function!(model, i, fct[i])
    else
        # Si un type de cellule est supérieur à la taille de fct, on pourrait définir une fonction par défaut
        # Ici, on pourrait réutiliser la dernière fonction ou une fonction constante.
        ShapeGrowthModels.set_max_function!(model, i, fct[end])
    end
end

# Exécution de la simulation
ShapeGrowthModels.run!(model)

# Visualisation des résultats
script_name = splitext(basename(@__FILE__))[1]
output_directory = "../expl/"
filename = joinpath(output_directory, "10fct_rand130types_$(script_name).gif")

ShapeGrowthModels.visualize(model,filename)