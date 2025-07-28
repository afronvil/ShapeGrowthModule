using PlotlyJS 
using ColorTypes # Nécessaire pour le type RGB

import ..ShapeGrowthModule 

block_size_rows = 5
block_size_cols = 5
function visualization(model::CellModel{Dim}) where Dim 
    cell_type_sequence=model.cell_type_sequence
    script_name = if Base.source_path() !== nothing
        splitext(basename(Base.source_path()))[1]
    else
        "simulation_script" 
    end
    
    base_output_dir = "../results/"

    specific_output_dir = joinpath(base_output_dir, script_name)
    output_dir_2D = joinpath(specific_output_dir, "2D")
    output_dir_3D = joinpath(specific_output_dir, "3D")

    if !isdir(specific_output_dir)
        mkpath(specific_output_dir)
        #println("DEBUG: Répertoire de sortie créé : ", specific_output_dir)
    end

    if !isdir(output_dir_2D)
        mkpath(output_dir_2D) 
        #println("DEBUG: Répertoire de sortie créé : ", output_dir_2D)
    end

    if !isdir(output_dir_3D)
        mkpath(output_dir_3D) 
        #println("DEBUG: Répertoire de sortie créé : ", output_dir_3D)
    end
    if Dim == 2 
        # Visualisation du DERNIER état 2D (image statique)
        # Utiliser la chaîne de la séquence dans le nom du fichier
        final_image_filename_2D = joinpath(output_dir_2D, "$(cell_type_sequence)_final_state_Dim2.png")
        visualize_final_state_2D(model, final_image_filename_2D, block_size_rows, block_size_cols)
        #println("DEBUG: Image 2D de l'état final sauvegardée : ", final_image_filename_2D)

        # Visualisation de TOUT L'HISTORIQUE 2D (animation GIF)
        # Utiliser la chaîne de la séquence dans le nom du fichier
        animation_filename_2D = joinpath(output_dir_2D, "$(cell_type_sequence)_history_Dim2.gif")
        visualize_history_animation_2D(model, animation_filename_2D, block_size_rows, block_size_cols, 10) 
        #println("DEBUG: Animation 2D de l'historique sauvegardée : ", animation_filename_2D)

    else # Implies DIM == 3
        # Visualisation du DERNIER état 3D (fenêtre PlotlyJS interactive)
        visualize_3D_cells(model, Dim, cell_type_sequence) 
        #println("DEBUG: Visualisation 3D interactive de l'état final affichée.")

        # Visualisation de TOUT L'HISTORIQUE 3D (frames HTML interactives dans un dossier)
        # Créer un sous-dossier unique pour les frames 3D basé sur la séquence
        visualize_history_3D_plotly_frames(model, Dim, output_dir_3D)
        #println("DEBUG: Les frames 3D interactives de l'historique sont sauvegardées dans le dossier: ", output_dir_3D)
    end 
end