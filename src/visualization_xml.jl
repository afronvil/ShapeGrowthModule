# This file should be part of your ShapeGrowthModels module, e.g., in src/visualization_xml.jl

using Plots
using ColorTypes # Assuming ColorTypes is needed for RGB

"""
    create_color_matrix(cell_set, grid_size, cell_data)

Creates an RGB color matrix from cell data.

# Arguments
- `cell_set`: The set of cells, typically a `CellSetByCoordinates` instance.
- `grid_size`: The size of the grid as a `Tuple{Int64, Int64}`.
- `cell_data`: Dictionary mapping cell types to their properties, including "color".

# Returns
A matrix of RGB colors.
"""
function create_color_matrix(cell_set::CellSetByCoordinates, grid_size::Tuple{Int64, Int64}, cell_data::Dict{Int64, Dict{String, Any}})
    # Initialize a matrix filled with black (RGB(0.0, 0.0, 0.0)) with the given grid_size.
    color_matrix = fill(RGB(0.0, 0.0, 0.0), grid_size)
    
    # Iterate through each cell in the cell_set
    for (coords, cell) in cell_set.cells
        x, y = coords # Extract x and y coordinates
        
        # Check if the coordinates are within the bounds of the color_matrix
        if checkbounds(Bool, color_matrix, x, y)
            type_id = cell.cell_type # Get the cell's type ID
            
            # Assign the color from cell_data based on the cell's type_id
            # This line is the source of `KeyError` if `type_id` is not in `cell_data`
            color_matrix[x, y] = cell_data[type_id]["color"]
            
            # Annotations logic was commented out in plot_cell_state, so it's removed here.
            # If annotations are desired, uncomment the relevant lines in plot_cell_state
            # and re-add the `annotations` variable and push! logic.
        end
    end

    # Return only the color matrix, as annotations are no longer used
    return color_matrix
end


"""
    plot_cell_state(color_matrix, step)

Visualizes the state of cells on a grid using a colored heatmap.

# Arguments
- `color_matrix`: The RGB color matrix representing the grid state.
- `step`: The current simulation step number.
"""
function plot_cell_state(color_matrix::Matrix{RGB{Float64}}, step::Int64)
    # Create a heatmap plot
    heatmap(color_matrix,
            title="Step $step", # Plot title showing the current step
            xaxis=false,        # Hide x-axis ticks and labels
            yaxis=false,        # Hide y-axis ticks and labels
            aspect_ratio=:equal,# Ensure cells are square
            colorbar=false      # Hide the color bar
            # Annotations were commented out, so they are removed from the function signature and call.
            )
end


"""
    visualize_cells(cell_set, step, grid_size, cell_data)

Orchestrates the creation of the color matrix and plotting of the heatmap for a single step.
"""
function visualize_cells(cell_set::CellSetByCoordinates, step::Int64, grid_size::Tuple{Int64, Int64}, 
    cell_data::Dict{Int64, Dict{String, Any}})
    # Create the color matrix from the current cell set
    color_matrix = create_color_matrix(cell_set, grid_size, cell_data) 
    # Display the cell state using the generated color matrix
    plot_cell_state(color_matrix, step) 
end


"""
    visualize_history(history, grid_size, cell_data)

Creates an animation of the cell evolution over multiple simulation steps.

# Arguments
- `history`: A vector of `CellSetByCoordinates` instances, representing the state at each step.
- `grid_size`: The size of the simulation grid.
- `cell_data`: Dictionary mapping cell types to their properties (e.g., colors).
"""
function visualize_history(history::Vector{CellSetByCoordinates}, grid_size::Tuple{Int64, Int64}, 
                        cell_data::Dict{Int64, Dict{String, Any}},
                        filename)    
    # Create an animation by iterating through the history of cell sets
    anim = @animate for (step, cell_set) in enumerate(history)
        # For each step, create the color matrix and plot the cell state
        color_matrix = create_color_matrix(cell_set, grid_size, cell_data) 
        plot_cell_state(color_matrix, step)  
    end

    # Save the animation as a GIF file
    
    gif(anim, filename, fps=2)
end


"""
    visualize(model::ShapeGrowthModels.CellModel)

High-level function to trigger visualization of the entire simulation history stored in the model.
Assumes `model` has a `history` field containing the vector of cell sets.
"""
function visualize(model::ShapeGrowthModels.CellModel,filename)
    # Call the visualize_history function using data from the model instance
    ShapeGrowthModels.visualize_history(model.history, model.grid_size, model.cell_data, filename)
end