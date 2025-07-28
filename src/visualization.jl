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
        #println("DEBUG: Output directory created: ", specific_output_dir)
    end

    if !isdir(output_dir_2D)
        mkpath(output_dir_2D) 
       #println("DEBUG: Output directory created: ", output_dir_2D)
    end

    if !isdir(output_dir_3D)
        mkpath(output_dir_3D) 
        #println("DEBUG: Output directory created: ", output_dir_3D)
    end
    if Dim == 2 
        # View LAST 2D state (static image)
        # Use sequence string in file name
        final_image_filename_2D = joinpath(output_dir_2D, "$(cell_type_sequence)_final_state_Dim2.png")
        visualize_final_state_2D(model, final_image_filename_2D, block_size_rows, block_size_cols)
        #println("DEBUG: 2D image of final state saved: ", final_image_filename_2D)
        # View ALL 2D HISTORY (GIF animation)
        # Use sequence string in file name
        animation_filename_2D = joinpath(output_dir_2D, "$(cell_type_sequence)_history_Dim2.gif")
        visualize_history_animation_2D(model, animation_filename_2D, block_size_rows, block_size_cols, 10) 
        #println("DEBUG: 2D history animation saved: ", animation_filename_2D)
    else # Implies DIM == 3
        # LAST 3D status display (interactive PlotlyJS window)
        visualize_3D_cells(model, Dim, cell_type_sequence) 
        # View ALL 3D HISTORY (interactive HTML frames in one folder)
        # Create a unique subfolder for 3D frames based on sequence
        visualize_history_3D_plotly_frames(model, Dim, output_dir_3D)
        #println("DEBUG: History interactive 3D frames are saved in folder: ", output_dir_3D)    
    end 
end