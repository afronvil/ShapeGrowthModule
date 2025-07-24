# ~/Nextcloud/Logiciels/ShapeGrowthModule/src/visualization_3D.jl

using PlotlyJS 
using ColorTypes # Nécessaire pour le type RGB

import ..ShapeGrowthModule 

"""
    visualize_3D_cells(model::ShapeGrowthModule.CellModel{3}, Dim::Int, cell_type_sequence::Vector{Int})

Génère une visualisation 3D interactive des cellules à partir du dernier état du modèle fourni
en utilisant PlotlyJS, en utilisant les couleurs spécifiées dans le fichier XML du modèle.
Les cellules sont représentées comme des points colorés.
"""
function visualize_3D_cells(model::ShapeGrowthModule.CellModel{3}, Dim::Int, cell_type_sequence::Vector{Int})
    println("DEBUG: Début de la visualisation 3D de l'état final avec couleurs XML.")

    if Dim != 3
        @warn "Dim n'est pas égal à 3. La visualisation Scatter3D est optimisée pour Dim = 3. Actuellement Dim = $(Dim)."
    end

    if isempty(model.history)
        @warn "L'historique du modèle est vide. Impossible de visualiser les cellules 3D."
        return
    end
    
    cells_to_visualize = model.history[end].cells 

    cell_x = Float64[]
    cell_y = Float64[]
    cell_z = Float64[]
    cell_colors_rgb_strings = String[] # Pour stocker les couleurs sous forme de chaînes "rgb(R,G,B)"

    for (coords, cell) in cells_to_visualize
        push!(cell_x, Float64(coords[1]))
        push!(cell_y, Float64(coords[2]))
        if Dim >= 3
            push!(cell_z, Float64(coords[3]))
        else
            push!(cell_z, 0.0) 
        end
        
        # Récupérer la couleur RGB de la cellule depuis model.cell_data
        cell_color_rgb = get(model.cell_data[cell.cell_type], "color", RGB(0.5, 0.5, 0.5)) # Gris par défaut
        
        # Convertir l'objet RGB en chaîne PlotlyJS "rgb(R,G,B)" (valeurs de 0 à 255)
        r = round(Int, cell_color_rgb.r * 255)
        g = round(Int, cell_color_rgb.g * 255)
        b = round(Int, cell_color_rgb.b * 255)
        push!(cell_colors_rgb_strings, "rgb($r,$g,$b)")
    end

    if isempty(cell_x)
        @warn "Aucune cellule à visualiser dans le dernier état."
        return
    end

    trace = PlotlyJS.scatter3d(
        x=cell_x,
        y=cell_y,
        z=cell_z,
        mode="markers",
        marker=PlotlyJS.attr(
            size=5,
            color=cell_colors_rgb_strings, # <<< Utiliser les chaînes de couleurs directes
            # colorscale="Viridis", # N'est plus nécessaire
            # cmin=isempty(cell_type_sequence) ? 0 : minimum(cell_type_sequence), # N'est plus nécessaire
            # cmax=isempty(cell_type_sequence) ? 1 : maximum(cell_type_sequence), # N'est plus nécessaire
            # colorbar_title="Cell Type", # N'est plus pertinent avec des couleurs directes non mappées
            opacity=0.8
        ),
        name="Cellules"
    )

    layout = PlotlyJS.Layout(
        title="Répartition 3D des Cellules (Dernier état de la simulation)",
        scene=PlotlyJS.attr(
            xaxis_title="X Coordinate",
            yaxis_title="Y Coordinate",
            zaxis_title="Z Coordinate",
            aspectmode="data" 
        ),
        hovermode="closest"
    )

    plot_obj = PlotlyJS.plot(trace, layout)
    PlotlyJS.display(plot_obj) 

    println("DEBUG: Visualisation PlotlyJS Scatter3D générée pour les cellules 3D.")
    return plot_obj 
end


"""
    visualize_history_3D_plotly_frames(model::ShapeGrowthModule.CellModel{3}, output_dir::String)

Génère une série de fichiers HTML PlotlyJS, un pour chaque étape de l'historique 3D,
en utilisant les couleurs spécifiées dans le fichier XML du modèle.
Chaque fichier représente l'état des cellules à cette étape et est interactif.
"""
function visualize_history_3D_plotly_frames(model::ShapeGrowthModule.CellModel{3},Dim::Int, output_dir::String)
    println("DEBUG: Début de la génération des frames 3D interactives de l'historique avec couleurs XML.")

    if Dim != 3
        @warn "Cette fonction est optimisée pour Dim = 3. Actuellement Dim = $(Dim)."
    end

    if isempty(model.history)
        @warn "L'historique du modèle est vide. Impossible de générer des frames 3D."
        return
    end

    if !isdir(output_dir)
        mkpath(output_dir) 
    end

    # Déterminer les limites maximales de la grille pour les axes 3D (pour la consistance)
    max_x = model.grid_size[1]
    max_y = model.grid_size[2]
    max_z = Dim >= 3 ? model.grid_size[3] : 1
    
    # Couleur par défaut si non trouvée
    default_color_rgb_string = "rgb(128,128,128)" # Gris

    for (step_idx, history_entry) in enumerate(model.history)
        cells_at_step = history_entry.cells
        
        cell_x = Float64[]
        cell_y = Float64[]
        cell_z = Float64[]
        cell_colors_rgb_strings = String[] 

        for (coords, cell) in cells_at_step
            push!(cell_x, Float64(coords[1]))
            push!(cell_y, Float64(coords[2]))
            if Dim >= 3
                push!(cell_z, Float64(coords[3]))
            else
                push!(cell_z, 0.0)
            end
            
            cell_color_rgb = get(model.cell_data[cell.cell_type], "color", RGB(0.5, 0.5, 0.5))
            r = round(Int, cell_color_rgb.r * 255)
            g = round(Int, cell_color_rgb.g * 255)
            b = round(Int, cell_color_rgb.b * 255)
            push!(cell_colors_rgb_strings, "rgb($r,$g,$b)")
        end

        if isempty(cell_x)
            @warn "Aucune cellule à visualiser à l'étape $(step_idx-1). Création d'un plot vide."
            trace = PlotlyJS.scatter3d() # Créer un trace vide pour les étapes sans cellules
        else
            trace = PlotlyJS.scatter3d(
                x=cell_x,
                y=cell_y,
                z=cell_z,
                mode="markers",
                marker=PlotlyJS.attr(
                    size=5,
                    color=cell_colors_rgb_strings, 
                    # colorscale="Viridis", # N'est plus nécessaire
                    # cmin, cmax, colorbar_title non pertinents ici
                    opacity=0.8
                ),
                name="Cellules"
            )
        end
        
        layout = PlotlyJS.Layout(
            title="Étape $(step_idx-1) de la simulation",
            scene=PlotlyJS.attr(
                xaxis_title="X Coordinate",
                yaxis_title="Y Coordinate",
                zaxis_title="Z Coordinate",
                xaxis=PlotlyJS.attr(range=[0, max_x]), 
                yaxis=PlotlyJS.attr(range=[0, max_y]),
                zaxis=PlotlyJS.attr(range=[0, max_z]),
                aspectmode="data" 
            ),
            hovermode="closest"
        )
        
        plot_obj = PlotlyJS.plot(trace, layout)
        
        output_filepath = joinpath(output_dir, "step_$(lpad(step_idx-1, 3, '0')).html")
        PlotlyJS.savefig(plot_obj, output_filepath)
        println("DEBUG: Frame 3D pour l'étape $(step_idx-1) sauvegardée en : $output_filepath")
    end
    println("DEBUG: Génération des frames 3D de l'historique terminée.")
end

