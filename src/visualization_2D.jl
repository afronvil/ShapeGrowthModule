# src/visualization_2D.jl
using ShapeGrowthModule

"""
    visualize_final_state_2D(model::CellModel{2}, output_filename::String, block_size_rows::Int, block_size_cols::Int)

Generates a 2D image (heatmap) of the last cell state on the grid, using
the colors specified in the template XML file.
Each cell is visualized as a block of `block_size_rows` x `block_size_cols` pixels.

# Arguments
- `model::CellModel{2}`: The simulation model instance (must be Dim=2).
- `output_filename::String`: The full path and name of the image file to be saved (e.g. "output.png").
- `block_size_rows::Int`: The number of pixel rows each logical cell occupies.
- `block_size_cols::Int`: The number of pixel columns each logical cell occupies.
"""
function visualize_final_state_2D(model::CellModel, output_filename::String, block_size_rows::Int, block_size_cols::Int)
    if isempty(model.history)
        @warn "The model history is empty. Cannot view final state."
        return
    end

    final_state_tissue_cells = model.history[end].tissue_cells
    final_stromal_tissue_cells= model.history[end].stromal_tissue_cells

    grid_rows_pixels = model.grid_size[1] * block_size_rows
    grid_cols_pixels = model.grid_size[2] * block_size_cols
    
    background_color = RGB(0.0, 0.0, 0.0)
    grid_matrix_pixels = fill(background_color, grid_rows_pixels, grid_cols_pixels)

    # Fill the pixel matrix with data from the non-stromal tissue_cells
    for (coords, cell) in final_state_tissue_cells
        r_meta, c_meta = coords[1], coords[2]

        start_r_pixel = (r_meta - 1) * block_size_rows + 1
        start_c_pixel = (c_meta - 1) * block_size_cols + 1
        
        cell_color = get(model.cell_data[Symbol(cell.cell_type)], "color", RGB(0.5, 0.5, 0.5))
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
    
    # Overlay the stromal tissue_cells
    for (coords, stromal_cell) in final_stromal_tissue_cells
        r_meta, c_meta = coords[1], coords[2]

        start_r_pixel = (r_meta - 1) * block_size_rows + 1
        start_c_pixel = (c_meta - 1) * block_size_cols + 1
        
        # Get the color for the stromal cell
        stromal_cell_color = get(model.cell_data[stromal_cell.cell_type], "color", RGB(0.5, 0.5, 0.5))
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

    heatmap_plot = Plots.heatmap(grid_matrix_pixels,
            title="Final cell status (2D - Dim: 2, Cells: $(block_size_rows)x$(block_size_cols))",
            aspect_ratio=:equal,
            xlims=(0.5, grid_cols_pixels + 0.5), 
            ylims=(0.5, grid_rows_pixels + 0.5), 
            xticks=nothing, yticks=nothing, 
            xlabel="", ylabel="", 
            size=(700, 700)) 

    Plots.savefig(heatmap_plot, output_filename)
end

"""
visualize_history_animation_2D(model::CellModel{2}, output_filename::String, block_size_rows::Int, block_size_cols::Int, fps::Int=10)

Generates a GIF animation of the evolution of 2D tissue_cells through the simulation history,
using the colors specified in the model XML file.

# Arguments
- `model::CellModel{2}`: The simulation model instance (must be Dim=2).
- output_filename::String`: The full path and name of the GIF file to be saved (e.g. "animation.gif").
- `block_size_rows::Int`: The number of pixel rows each logical cell occupies.
- `block_size_cols::Int`: The number of columns of pixels each logical cell occupies.
- fps::Int`: Frames per second for animation.
"""
function visualize_history_animation_2D(model::CellModel, output_filename::String, block_size_rows::Int, block_size_cols::Int, fps::Int=10)
    if isempty(model.history)
        @warn "The model history is empty. Unable to generate 2D animation."
        return
    end

    grid_rows_pixels = model.grid_size[1] * block_size_rows
    grid_cols_pixels = model.grid_size[2] * block_size_cols
    background_color = RGB(0.0, 0.0, 0.0)
       
    anim = @animate for (step_idx, history_entry) in enumerate(model.history)
        # Create a single pixel matrix for this frame
        grid_matrix_pixels = fill(background_color, grid_rows_pixels, grid_cols_pixels)

        # Fill with regular tissue_cells first
        for (coords, cell) in history_entry.tissue_cells   
            r_meta, c_meta = coords[1], coords[2] 
            start_r_pixel = (r_meta - 1) * block_size_rows + 1
            start_c_pixel = (c_meta - 1) * block_size_cols + 1
            cell_color = get(model.cell_data[cell.cell_type], "color", RGB(0.5, 0.5, 0.5))
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
        
        # Overlay with stromal tissue_cells
        for (coords, stromal_cell) in history_entry.stromal_tissue_cells   
            r_meta, c_meta = coords[1], coords[2] 
            start_r_pixel = (r_meta - 1) * block_size_rows + 1
            start_c_pixel = (c_meta - 1) * block_size_cols + 1
            stromal_cell_color = get(model.cell_data[stromal_cell.cell_type], "color", RGB(0.5, 0.5, 0.5))
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
        
        Plots.heatmap(grid_matrix_pixels,
                title="Step $(step_idx-1) (2D - Dim: 2, Cells: $(block_size_rows)x$(block_size_cols))",
                aspect_ratio=:equal,
                xlims=(0.5, grid_cols_pixels + 0.5), 
                ylims=(0.5, grid_rows_pixels + 0.5), 
                xticks=nothing, yticks=nothing, 
                xlabel="", ylabel="",
                size=(700, 700))
    end
        
    Plots.gif(anim, output_filename, fps=fps)
end