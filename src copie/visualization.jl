using ColorSchemes
using Plots
"""Visualise l'état des cellules sur une grille."""
function visualize_cells(cell_set::CellSetByCoordinates, step::Int64, grid_size::Tuple{Int64, Int64})
    matrix = zeros(Int64, grid_size...)
    colors = ColorSchemes.tol_muted
    num_colors = length(colors)
    annotations = []
    for (coords, cell) in cell_set.cells
        if checkbounds(Bool, matrix, coords...)
            matrix[coords...] = mod1(cell.cell_type, num_colors)
            push!(annotations, (coords[2], coords[1], Plots.text(string(cell.nbdiv), 8, :black, :center)))
        end
    end
    heatmap(matrix, title="Étape $step", colormap=Colorant[colorant"black", colorant"blue", colorant"white", colorant"red", colorant"green", colorant"orange"],
            clim=(0, 5), aspect_ratio=1, annotations=annotations)
end
