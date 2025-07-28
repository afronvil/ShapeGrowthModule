# ~/Nextcloud/Logiciels/ShapeGrowthModule/src/visualization_3D.jl

using PlotlyJS 
using ColorTypes # Nécessaire pour le type RGB

import ..ShapeGrowthModule 

"""
   visualize_3D_cells(model::CellModel{3}, Dim::Int, cell_type_sequence::Vector{Int})

Generates an interactive 3D visualization of cells from the latest model state provided
using PlotlyJS, using the colors specified in the model XML file.
Cells are represented as colored points.
"""
function visualize_3D_cells(model::CellModel{3}, Dim::Int, cell_type_sequence::Vector{Int})
    println("DEBUG: Start of 3D visualization of final state with XML colors.")

    if Dim != 3
        @warn "Dim is not equal to 3. Scatter3D visualization is optimized for Dim = 3. Currently Dim = $(Dim)."
    end

    if isempty(model.history)
        @warn "The model history is empty. 3D cells cannot be viewed."
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
        @warn "No cells to view in last state."
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
            opacity=0.8
        ),
        name="Cells"
    )

    layout = PlotlyJS.Layout(
        title="3D cell distribution (latest simulation status)",
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

    println("DEBUG: PlotlyJS Scatter3D visualization generated for 3D cells.")
    return plot_obj 
end

"""
 visualize_history_3D_plotly_frames(model::CellModel{3}, output_dir::String)

Generates a series of PlotlyJS HTML files, one for each stage of the 3D history,
using the colors specified in the model XML file.
Each file represents the state of the cells at that stage and is interactive.
"""
function visualize_history_3D_plotly_frames(model::CellModel{3},Dim::Int, output_dir::String)
    println("DEBUG: Start of generation of interactive 3D history frames with XML colors.")

    if Dim != 3
        @warn "This function is optimized for Dim = 3. Currently Dim = $(Dim)."
    end

    if isempty(model.history)
        @warn "The model history is empty. Unable to generate 3D frames."
        return
    end

    if !isdir(output_dir)
        mkpath(output_dir) 
    end

    # Set maximum grid limits for 3D axes
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
            @warn "No cells to be displayed at step $(step_idx-1). Creation of an empty plot."
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
            title="Simulation step $(step_idx-1)",
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
        println("DEBUG: 3D frame for step $(step_idx-1) saved in : $output_filepath")
    end
    println("DEBUG: Generation of 3D history frames completed.")
end

