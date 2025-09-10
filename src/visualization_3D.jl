# src/visualization_3D.jl

using PlotlyJS 
using ColorTypes # Required for the RGB type

import ..ShapeGrowthModule

"""
    _extract_cell_data_for_plot(model::CellModel, cells_dict::Dict)

Extracts coordinates and colors from a dictionary of cells for PlotlyJS visualization.
Returns two vectors: one for coordinates (as tuples) and one for color strings.
"""
function _extract_cell_data_for_plot(model::CellModel, cells_dict::Dict)
    cell_x = Float64[]
    cell_y = Float64[]
    cell_z = Float64[]
    cell_colors_rgb_strings = String[]

    Dim = length(model.grid_size)

    for (coords, cell) in cells_dict
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

    return cell_x, cell_y, cell_z, cell_colors_rgb_strings
end

"""
   visualize_3D_cells(model::CellModel)

Generates an interactive 3D visualization of cells from the latest model state
using PlotlyJS.
"""
function visualize_3D_cells(model::CellModel)
    Dim = length(model.grid_size)
    if Dim != 3
        @warn "Dim is not equal to 3. Scatter3D visualization is optimized for Dim = 3. Currently Dim = $(Dim)."
    end

    if isempty(model.history)
        @warn "The model history is empty. 3D cells cannot be viewed."
        return
    end

    # Get the latest state
    latest_cells = model.history[end].cells
    latest_stromal_cells = model.history[end].stromal_cells

    # Extract data for both cell types
    cell_x, cell_y, cell_z, cell_colors_rgb_strings = _extract_cell_data_for_plot(model, latest_cells)
    
    stromal_x, stromal_y, stromal_z, stromal_colors = _extract_cell_data_for_plot(model, latest_stromal_cells)

    # Combine data from all cell types
    all_x = vcat(cell_x, stromal_x)
    all_y = vcat(cell_y, stromal_y)
    all_z = vcat(cell_z, stromal_z)
    all_colors = vcat(cell_colors_rgb_strings, stromal_colors)

    if isempty(all_x)
        @warn "No cells to view in last state."
        return
    end

    trace = PlotlyJS.scatter3d(
        x=all_x,
        y=all_y,
        z=all_z,
        mode="markers",
        marker=PlotlyJS.attr(
            size=5,
            color=all_colors,
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
    
    return plot_obj 
end

"""
 visualize_history_3D_plotly_frames(model::CellModel, output_dir::String)

Generates a series of PlotlyJS HTML files, one for each stage of the 3D history.
"""
function visualize_history_3D_plotly_frames(model::CellModel, output_dir::String)
    Dim = length(model.grid_size)
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

    # Set consistent axis limits for all frames
    max_x = model.grid_size[1]
    max_y = model.grid_size[2]
    max_z = Dim >= 3 ? model.grid_size[3] : 1
    
    for (step_idx, history_entry) in enumerate(model.history)
        # Extract data for both cell types for the current step
        cell_x, cell_y, cell_z, cell_colors = _extract_cell_data_for_plot(model, history_entry.cells)
        stromal_x, stromal_y, stromal_z, stromal_colors = _extract_cell_data_for_plot(model, history_entry.stromal_cells)

        # Combine all data
        all_x = vcat(cell_x, stromal_x)
        all_y = vcat(cell_y, stromal_y)
        all_z = vcat(cell_z, stromal_z)
        all_colors = vcat(cell_colors, stromal_colors)
        
        if isempty(all_x)
            @warn "No cells to be displayed at step $(step_idx-1). Creation of an empty plot."
            trace = PlotlyJS.scatter3d()
        else
            trace = PlotlyJS.scatter3d(
                x=all_x,
                y=all_y,
                z=all_z,
                mode="markers",
                marker=PlotlyJS.attr(
                    size=5,
                    color=all_colors, 
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
    end
    println("Generation of 3D history frames completed.")
end