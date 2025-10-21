# src/visualization.jl
using ShapeGrowthModule
"""
    visualization(model::CellModel)

Handles all visualization tasks for the cellular automaton model, dispatching
to the appropriate 2D or 3D functions based on the model's dimension.
"""
function visualization(model::CellModel)
    # Get the dimension directly from the model's grid_size
    Dim = length(model.grid_size)
    
    # 1. Define output directories based on script name and dimension
    script_name = if Base.source_path() !== nothing
        splitext(basename(Base.source_path()))[1]
    else
        "simulation_script"
    end
    
    base_output_dir = "expl/results/"
    specific_output_dir = joinpath(base_output_dir, script_name)
    output_dir = joinpath(specific_output_dir, "$(Dim)D")
    
    if !isdir(output_dir)
        mkpath(output_dir)
       #println("Output directory created: ", output_dir)
    end

    cell_type_sequence = model.cell_type_sequence
    sequence_string = join(cell_type_sequence, "_")
    
    # 2. Call the visualization functions based on dimension
    if Dim == 2
        # Define visualization-specific parameters
        block_size_rows = 5
        block_size_cols = 5
        animation_fps = 10 # Frames per second for the GIF

        # Visualize the LAST 2D state (static image)
        final_image_filename = joinpath(output_dir, "$(sequence_string)_final_state_Dim2.png")
        visualize_final_state_2D(model, final_image_filename, block_size_rows, block_size_cols)
       #println("2D image of final state saved: ", final_image_filename)
        
        # Visualize ALL 2D HISTORY (GIF animation)
        animation_filename = joinpath(output_dir, "$(sequence_string)_history_Dim2.gif")
        visualize_history_animation_2D(model, animation_filename, block_size_rows, block_size_cols, animation_fps)
       #println("2D history animation saved: ", animation_filename)

    elseif Dim == 3
        # Visualize LAST 3D state (interactive PlotlyJS window)
        visualize_3D_cells(model)
        
        # Visualize ALL 3D HISTORY (interactive HTML frames in one folder)
        visualize_history_3D_plotly_frames(model, output_dir)
       #println("Interactive 3D history frames are saved in folder: ", output_dir)
    end
end