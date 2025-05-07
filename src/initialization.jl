include("functions.jl")

include("data_xml.jl")
include("visualization_xml.jl")

include("struct_cell_env.jl")
# --- Initialisation et paramètres ---
cell_types_sequence = [4,2,1]
max_div_sequence = [5, 10, 5, 5] 
cell_types_sequence = [1, 2, 3, 1]

# --- Initialisation et paramètres ---

xml_file = "cellTypes.xml"

num_steps = 25
grid_size = (30, 30)
#max_cell_division = 6




cases = Dict(
    1 => [(0, -1)], #Ouest
    2 => [(-1, 0)], #Nord
    3 => [(0, 1)],  #Est
    4 => [(1, 0)],  #Sud
    5 => [(1, -1)], #Sud-Ouest
    6 => [(-1, -1)],#Nord-Ouest
    7 => [(1, 1)], #Sud-Est
    8 => [(-1, 1)]#Nord-Est
)






# --- Initial cell configuration ---
initial_cells = CellSetByCoordinates(Dict(
    (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))) =>
        Cell(
            (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))),
            0,
            cell_types_sequence[1],
            cell_types_sequence[1],  # initial_cell_type
            cell_types_sequence[1],
            0,
            0, #initial_nbdiv
            true,
            false,
            1     # current_type_index_in_sequence
        )
    ))






"""Lance la simulation cellulaire."""

function run_simulation(initial_cells::CellSetByCoordinates, num_steps::Int64, grid_size::Tuple{Int64, Int64},  cell_type_sequence::Vector{Int64}; xml_file::String = "cellTypesChange.xml")
    history = [deepcopy(initial_cells)]
    current_cells = deepcopy(initial_cells)
    cell_data=load_cell_data(xml_file, cell_types_sequence)
    max_cell_divisions = create_max_cell_divisions_dict(cell_data)
    cell_directions = create_directions(cell_data)
    proliferation_directions = create_directions_dict(cell_directions, cases)
    
    anim = @animate for step in 0:num_steps
        visualize_cells(current_cells, step, grid_size, cell_data)
        if step < num_steps
            current_cells = simulate_step!(current_cells, proliferation_directions, cell_type_sequence, max_cell_divisions, grid_size)
            push!(history, deepcopy(current_cells))
        end
    end
    gif(anim, "cellular_dynamics.gif", fps=1)
    println("Simulation terminée (mise à jour après tous les types) et la visualisation a été sauvegardée.")
    # anim2 = @animate for i in 1:length(history)
    #     visualize_cells(history[i], i - 1, grid_size, cell_type_colors)
    # end
    # gif(anim2, "cellular_dynamics_history.gif", fps=1)
end
