"""
    Cell

Représente une cellule individuelle dans la simulation.
"""
mutable struct Cell
    id::UUID                # Identifiant unique de la cellule
    coordinates::Tuple{Float64, Float64} # Coordonnées (x, y) de la cellule, par exemple
    division_count::Int     # Nombre de divisions que cette cellule a subies
    generation::Int         # La génération de la cellule (1 pour la cellule initiale, 2 pour ses filles, etc.)
    parent_id::Union{UUID, Nothing} # ID de la cellule parente (Nothing si c'est la cellule initiale)
    born_at::DateTime       # Horodatage de la création de la cellule
    # Ajoutez d'autres propriétés si nécessaire, par exemple:
    # type::String
    # health::Float64
end