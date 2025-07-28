# ~/Nextcloud/Logiciels/ShapeGrowthModule/src/visualization_2D.jl

using Plots
using ColorTypes # Nécessaire pour le type RGB

# Pour référencer les types du module principal
import ..ShapeGrowthModule

"""
    visualize_final_state_2D(model::CellModel{2}, output_filename::String, block_size_rows::Int, block_size_cols::Int)

Génère une image 2D (heatmap) du dernier état des cellules sur la grille, en utilisant
les couleurs spécifiées dans le fichier XML du modèle.
Chaque cellule est visualisée comme un bloc de `block_size_rows` x `block_size_cols` pixels.

# Arguments
- `model::CellModel{2}`: L'instance du modèle de simulation (doit être de Dim=2).
- `output_filename::String`: Le chemin complet et le nom du fichier image à sauvegarder (ex: "output.png").
- `block_size_rows::Int`: Le nombre de rangées de pixels que chaque cellule logique occupe.
- `block_size_cols::Int`: Le nombre de colonnes de pixels que chaque cellule logique occupe.
"""
function visualize_final_state_2D(model::CellModel{2}, output_filename::String, block_size_rows::Int, block_size_cols::Int)
    println("DEBUG: Début de la visualisation 2D de l'état final avec couleurs XML.")

    if isempty(model.history)
        @warn "L'historique du modèle est vide. Impossible de visualiser l'état final."
        return
    end

    final_state_cells = model.history[end].cells
    final_stromal_cells= model.history[end].stromal_cells

    grid_rows_pixels = model.grid_size[1] * block_size_rows
    grid_cols_pixels = model.grid_size[2] * block_size_cols

    # Créer une matrice de pixels où chaque pixel contient une couleur RGB
    # Initialiser avec une couleur de fond (par exemple, noir ou blanc)
    # Plots accepte une matrice de couleurs pour heatmap
    background_color = RGB(0.0, 0.0, 0.0) # Noir par défaut pour les zones vides
    grid_matrix_pixels = fill(background_color, grid_rows_pixels, grid_cols_pixels)
    grid_stromal_matrix_pixels = fill(background_color, grid_rows_pixels, grid_cols_pixels)
    # Remplir la matrice de pixels avec les données des cellules
    for (coords, cell) in final_state_cells
        r_meta, c_meta = coords[1], coords[2]

        start_r_pixel = (r_meta - 1) * block_size_rows + 1
        start_c_pixel = (c_meta - 1) * block_size_cols + 1
        
        # Récupérer la couleur de la cellule depuis model.cell_data
        cell_color = get(model.cell_data[cell.cell_type], "color", RGB(0.5, 0.5, 0.5)) # Gris par défaut si couleur non trouvée
        for r_offset in 0:(block_size_rows-1)
            for c_offset in 0:(block_size_cols-1)
                current_r_pixel = start_r_pixel + r_offset
                current_c_pixel = start_c_pixel + c_offset
                if (1 <= current_r_pixel <= grid_rows_pixels && 1 <= current_c_pixel <= grid_cols_pixels)
                    grid_matrix_pixels[current_r_pixel, current_c_pixel] = cell_color
                    
                end
            end
        end
    end
    for (coords, stromal_cell) in final_stromal_cells
        r_meta, c_meta = coords[1], coords[2]

        start_r_pixel = (r_meta - 1) * block_size_rows + 1
        start_c_pixel = (c_meta - 1) * block_size_cols + 1
        
        # Récupérer la couleur de la cellule depuis model.cell_data
       stromal_cell_color = RGB(0.5, 0.5, 0.5) # Gris par défaut si couleur non trouvée
        for r_offset in 0:(block_size_rows-1)
            for c_offset in 0:(block_size_cols-1)
                current_r_pixel = start_r_pixel + r_offset
                current_c_pixel = start_c_pixel + c_offset
                if (1 <= current_r_pixel <= grid_rows_pixels && 1 <= current_c_pixel <= grid_cols_pixels)
                    grid_stromal_matrix_pixels[current_r_pixel, current_c_pixel] = stromal_cell_color
                end
            end
        end
    end

    # Créer et sauvegarder le heatmap
    # Quand on passe une matrice de couleurs, `c` et `clims` ne sont plus nécessaires
    heatmap_plot = Plots.heatmap(grid_matrix_pixels+length(model.stromal_cells)*grid_stromal_matrix_pixels,
            title="État Final des Cellules (2D - Dim: 2, Cellules: $(block_size_rows)x$(block_size_cols))",
            aspect_ratio=:equal,
            # c=:viridis, # N'est plus nécessaire car les couleurs sont directes
            # clims=(min_val_for_color_scale, max_val_for_color_scale > 0 ? max_val_for_color_scale : 1.0), # N'est plus nécessaire
            xlims=(0.5, grid_cols_pixels + 0.5), 
            ylims=(0.5, grid_rows_pixels + 0.5), 
            xticks=nothing, yticks=nothing, 
            xlabel="", ylabel="", 
            size=(700, 700)) 

    Plots.savefig(heatmap_plot, output_filename)
    println("DEBUG: Image 2D de l'état final sauvegardée en : $output_filename")
end

"""
    visualize_history_animation_2D(model::CellModel{2}, output_filename::String, block_size_rows::Int, block_size_cols::Int, fps::Int=10)

Génère une animation GIF de l'évolution des cellules 2D à travers l'historique de la simulation,
en utilisant les couleurs spécifiées dans le fichier XML du modèle.

# Arguments
- `model::CellModel{2}`: L'instance du modèle de simulation (doit être de Dim=2).
- `output_filename::String`: Le chemin complet et le nom du fichier GIF à sauvegarder (ex: "animation.gif").
- `block_size_rows::Int`: Le nombre de rangées de pixels que chaque cellule logique occupe.
- `block_size_cols::Int`: Le nombre de colonnes de pixels que chaque cellule logique occupe.
- `fps::Int`: Images par seconde pour l'animation.
"""
function visualize_history_animation_2D(model::CellModel{2}, output_filename::String, block_size_rows::Int, block_size_cols::Int, fps::Int=10)
    println("DEBUG: Début de la génération de l'animation 2D de l'historique avec couleurs XML.")

    if isempty(model.history)
        @warn "L'historique du modèle est vide. Impossible de générer l'animation 2D."
        return
    end

    grid_rows_pixels = model.grid_size[1] * block_size_rows
    grid_cols_pixels = model.grid_size[2] * block_size_cols
    background_color = RGB(0.0, 0.0, 0.0) # Couleur de fond pour les zones vides
       
    anim = @animate for (step_idx, history_entry) in enumerate(model.history)
        cells_at_step = history_entry.cells   
        # Initialiser la matrice de pixels pour cette frame
        grid_matrix_pixels = fill(background_color, grid_rows_pixels, grid_cols_pixels)
        grid_stromal_matrix_pixels = fill(background_color, grid_rows_pixels, grid_cols_pixels)              
    
        for (coords, cell) in cells_at_step
            r_meta, c_meta = coords[1], coords[2] 
            start_r_pixel = (r_meta - 1) * block_size_rows + 1
            start_c_pixel = (c_meta - 1) * block_size_cols + 1
            # Récupérer la couleur RGB de la cellule depuis model.cell_data
            cell_color = get(model.cell_data[cell.cell_type], "color", RGB(0.5, 0.5, 0.5)) # Gris par défaut
            # Remplir le bloc de pixels avec la couleur de la cellule
            for r_offset in 0:(block_size_rows-1)
                for c_offset in 0:(block_size_cols-1)
                    current_r_pixel = start_r_pixel + r_offset
                    current_c_pixel = start_c_pixel + c_offset
                    if (1 <= current_r_pixel <= grid_rows_pixels && 1 <= current_c_pixel <= grid_cols_pixels)
                        grid_matrix_pixels[current_r_pixel, current_c_pixel] = cell_color
                    end
                end
            end
        end
        stromal_cells_at_step = history_entry.stromal_cells   
        for (coords, stromal_cell) in stromal_cells_at_step
            r_meta, c_meta = coords[1], coords[2] 
            start_r_pixel = (r_meta - 1) * block_size_rows + 1
            start_c_pixel = (c_meta - 1) * block_size_cols + 1
            # Récupérer la couleur RGB de la cellule depuis model.cell_data
            stromal_cell_color = RGB(0.5, 0.5, 0.5) # Gris par défaut
            # Remplir le bloc de pixels avec la couleur de la cellule
            for r_offset in 0:(block_size_rows-1)
                for c_offset in 0:(block_size_cols-1)
                    current_r_pixel = start_r_pixel + r_offset
                    current_c_pixel = start_c_pixel + c_offset
                    if (1 <= current_r_pixel <= grid_rows_pixels && 1 <= current_c_pixel <= grid_cols_pixels)
                        grid_matrix_pixels[current_r_pixel, current_c_pixel] = stromal_cell_color
                    end
                end
            end
        end
        Plots.heatmap(grid_matrix_pixels+grid_stromal_matrix_pixels,
                title="Étape $(step_idx-1) (2D - Dim: 2, Cellules: $(block_size_rows)x$(block_size_cols))",
                aspect_ratio=:equal,
                xlims=(0.5, grid_cols_pixels + 0.5), 
                ylims=(0.5, grid_rows_pixels + 0.5), 
                xticks=nothing, yticks=nothing, 
                xlabel="", ylabel="",
                size=(700, 700))
    end
        
        Plots.gif(anim, output_filename, fps=fps)
        println("DEBUG: Animation 2D de l'historique sauvegardée en : $output_filename")
end

