# Dans ShapeGrowthModels/src/constants.jl

# Ce fichier contient des constantes globales utilisées à travers le module.

# Dictionnaire des directions de mouvement.
# Les clés sont des entiers représentant une direction, et les valeurs sont des tuples (dx, dy).
const cases = Dict(
    1 => [(0, -1)], # Ouest (changement en colonne)
    2 => [(-1, 0)], # Nord (changement en ligne)
    3 => [(0, 1)],  # Est (changement en colonne)
    4 => [(1, 0)],  # Sud (changement en ligne)
    5 => [(1, -1)], # Sud-Ouest
    6 => [(-1, -1)],# Nord-Ouest
    7 => [(1, 1)],  # Sud-Est
    8 => [(-1, 1)]  # Nord-Est
)

# # D'autres constantes globales pourraient être définies ici si nécessaire.
    
# max_cell_divisions_dict::Dict{Int64, Function} = Dict(
#     1 => (cell::Cell) -> fct1,
#     2 => (cell::Cell) -> fct2,
#     3 => (cell::Cell) -> fct3,
#     4 => (cell::Cell) -> fct4,
#     5 => (cell::Cell) -> fct5
# )
# # Exemple de fonctions pour calculer le nombre maximal de divisions

