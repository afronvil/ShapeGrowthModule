#!/usr/bin/env julia
using Plots
using ColorTypes


"""
Crée une matrice de couleurs RGB à partir des données des cellules.

# Arguments
- `cell_set`: L'ensemble des cellules.
- `grid_size`: La taille de la grille.
- `cell_type_colors`: Dictionnaire associant les types de cellules à leurs couleurs.

# Retourne
Une matrice de couleurs RGB.
"""
function create_color_matrix(cell_set::CellSetByCoordinates, grid_size::Tuple{Int64, Int64}, cell_data::Dict{Int64, Dict{String, Any}})
    color_matrix = fill(RGB(0.0, 0.0, 0.0), grid_size)
    annotations = []
    for (coords, cell) in cell_set.cells
        x, y = coords
        
        if checkbounds(Bool, color_matrix, x, y)
            type_id = cell.cell_type
            color_matrix[x, y] = cell_data[type_id]["color"]
            push!(annotations, (coords[2], coords[1], Plots.text(string(cell.nbdiv), 8, :black, :center)))
        end
    end

    return color_matrix, annotations
end


"""
Visualise l'état des cellules sur une grille à l'aide d'une heatmap colorée.

# Arguments
- `color_matrix`: La matrice des couleurs RGB représentant l'état de la grille.
- `step`: Le numéro de l'étape de la simulation.
"""
function plot_cell_state(color_matrix::Matrix{RGB{Float64}}, step::Int64, annotations)
    try
        heatmap(color_matrix,
                title="Étape $step",
                xlabel="X",
                ylabel="Y",
                aspect_ratio=:equal,
                colorbar=false,
                #annotations=annotations
                )
    catch e
        error("Erreur lors de la création du graphique : $e")
    end
end

"""
Fonction principale pour visualiser l'état des cellules.  Orchestre le chargement des couleurs,
la création de  zla matrice de couleurs, et le traçage de la heatmap.
"""


function visualize_cells(cell_set::CellSetByCoordinates, step::Int64, grid_size::Tuple{Int64, Int64}, 
    cell_data::Dict{Int64, Dict{String, Any}})
    color_matrix, annotations = create_color_matrix(cell_set, grid_size, cell_data) # Créer la matrice de couleurs
    plot_cell_state(color_matrix, step, annotations) # Afficher l'état
    

end
