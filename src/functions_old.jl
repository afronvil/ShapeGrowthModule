using ColorSchemes
using Plots
using ShapeGrowthModels

include("pdma.jl")
# --- Cellular Dynamics Functions ---

"""Updates the timer for living cells."""
function update_cell_state!(next_cells)
    for cell in values(next_cells)
        cell.is_alive && (cell.timer += 1)
    end
end

"""Resets the proliferation status for all cells at the beginning of a step."""
function reset_proliferation_status!(current_cells::ShapeGrowthModels.CellSetByCoordinates)
    for cell in values(current_cells.cells)
        cell.has_proliferated_this_step = false
    end
end

"""Simulates one step of cellular evolution."""
function simulate_step!(
    model::ShapeGrowthModels.CellModel,
    current_cells::ShapeGrowthModels.CellSetByCoordinates,
    proliferation_directions::Dict{Int64, Vector{Tuple{Int64, Int64}}},
    cell_type_sequence::Vector{Int64},
    grid_size::Tuple{Int64, Int64})
    reset_proliferation_status!(current_cells)
    next_cells_dict = deepcopy(current_cells.cells)
    for cell_type in cell_type_sequence
        cells_of_type = [cell for cell in values(current_cells.cells) if cell.is_alive && cell.cell_type == cell_type]
        for cell in cells_of_type
            # Check if cell_directions for this cell type is 0, if so, mark for removal
            cell_directions_for_type = model.cell_data[cell_type]["directions"]
            if isempty(cell_directions_for_type) || all(d == 0 for d in cell_directions_for_type)
                next_cells_dict[cell.coordinates] =
                    ShapeGrowthModels.Cell(cell.coordinates, cell.timer, cell.initial_cell_type, cell.cell_type,
                                            cell.last_division_type, cell.nbdiv, cell.initial_nbdiv,
                                            false, # is_alive = false, cell disappears
                                            cell.has_proliferated_this_step, cell.current_type_index_in_sequence)
            else
                max_cell_division = calculate_max_divisions(model, cell)
                attempt_proliferation!(next_cells_dict, current_cells, cell, proliferation_directions, max_cell_division, grid_size)
            end
        end
        for cell in cells_of_type
            if cell.is_alive && !cell.has_proliferated_this_step
                max_cell_division = calculate_max_divisions(model, cell)
                try_differentiate!(next_cells_dict, current_cells, cell_type_sequence, proliferation_directions, max_cell_division, grid_size, cell_type)
            end
        end
    end
    # Remove dead cells from the next state
    alive_next_cells = Dict(coord => cell for (coord, cell) in next_cells_dict if cell.is_alive)
    update_cell_state!(alive_next_cells)
    return ShapeGrowthModels.CellSetByCoordinates(alive_next_cells)
end

"""Converts a vector of integer directions to a vector of coordinate tuples (Int64, Int64)."""
function directions_to_tuples(directions::Vector{Int64}, cases::Dict{Int64, Vector{Tuple{Int64, Int64}}})
    new_directions = Vector{Tuple{Int64, Int64}}()
    for direction in directions
        if haskey(cases, direction)
            append!(new_directions, cases[direction])
        else
            push!(new_directions, (0, 0)) # default value
        end
    end
    return new_directions
end

"""
Returns `Dict{Int64, Vector{Int64}}`: A dictionary where keys are cell types and
values are the vectors of proliferation directions.
"""
function create_directions(cell_data::Dict{Int64, Dict{String, Any}})
    directions = Dict{Int64, Vector{Int64}}()
    for (cell_type, data) in cell_data
        directions[cell_type] = data["directions"]
    end
    return directions
end

function create_directions_dict(cell_directions::Dict{Int64, Vector{Int64}})
    cases = Dict(
        1 => [(0, 0)],  # Quiescence (aucun changement)
        2 => [(0, -1)], # Ouest (changement en colonne)
        3 => [(-1, 0)], # Nord (changement en ligne)
        4 => [(0, 1)],  # Est (changement en colonne)
        5 => [(1, 0)],  # Sud (changement en ligne)
        6 => [(1, -1)], # Sud-Ouest
        7 => [(-1, -1)],# Nord-Ouest
        8 => [(1, 1)],  # Sud-Est
        9 => [(-1, 1)]  # Nord-Est
    )

    result_dict = Dict{Int64, Vector{Tuple{Int64, Int64}}}()
    for (cell_type, directions) in cell_directions
        result_dict[cell_type] = directions_to_tuples(directions, cases)
    end
    println(result_dict)
    return result_dict
end

"""Retrieves the coordinates of all cells present in a cell set."""
function get_cell_coordinates(cell_set::ShapeGrowthModels.CellSetByCoordinates)
    return collect(keys(cell_set.cells))
end

"""
Calculates the maximum number of divisions a cell can perform,
based on its type, using the functions stored in the model.
"""
function calculate_max_divisions(model::ShapeGrowthModels.CellModel, cell::ShapeGrowthModels.Cell)
    if haskey(model.max_cell_divisions_dict, cell.cell_type)
        return model.max_cell_divisions_dict[cell.cell_type](cell)
    else
        return 1 # Default value if no function is defined for this type
    end
end

function cellular_dynamics(model::ShapeGrowthModels.CellModel, initial_cells::ShapeGrowthModels.CellSetByCoordinates, num_steps::Int64, grid_size::Tuple{Int64, Int64}, cell_type_sequence::Vector{Int64} = model.cell_type_sequence, xml_file::String = model.xml_file)
    cell_data = model.cell_data

    # Initialize history with the initial state
    history = [deepcopy(initial_cells)]

    # Initialize current_cells for the first iteration
    current_cells = deepcopy(initial_cells)

    # Pre-calculate cell directions and proliferation directions
    cell_directions = create_directions(cell_data)
    proliferation_directions = create_directions_dict(cell_directions)


    # Simulate the first step to get an initial 'new_cells' for comparison
    new_cells = ShapeGrowthModels.simulate_step!(model, current_cells, proliferation_directions, cell_type_sequence, grid_size)
    push!(history, deepcopy(new_cells)) # Add the state after the first step to history


    # Loop condition: Continue as long as cells are changing AND we are within the step limit
    step = 1


    while (!(get_cell_coordinates(current_cells) == get_cell_coordinates(new_cells)) && step <= num_steps)
        current_cells = new_cells
        new_cells = ShapeGrowthModels.simulate_step!(model, current_cells, proliferation_directions, cell_type_sequence, grid_size)
        push!(history, deepcopy(new_cells))
        step += 1
    end


    return history, step
end

# The run! function encapsulates the call to cellular_dynamics
function run!(model::ShapeGrowthModels.CellModel; num_steps::Int64 = 50)
    history_result, final_step = ShapeGrowthModels.cellular_dynamics(
        model,
        model.cells,         # Initial cells from the model
        num_steps,           # Maximum number of steps
        model.grid_size,     # Grid size from the model
        model.cell_type_sequence, # Cell type sequence from the model
        model.xml_file       # XML file from the model
    )
    model.history = history_result
    model.current_time = final_step
    return final_step
end

function create_new_cell(model::ShapeGrowthModels.CellModel, coordinates::Tuple{Int64, Int64}, cell_type::Int64)
    initial_nbdiv = ShapeGrowthModels.calculate_max_divisions(model, ShapeGrowthModels.Cell(coordinates, 0, cell_type, cell_type, 0, 0, 0, true, false, 1))
    new_cell = ShapeGrowthModels.Cell(
        coordinates,
        0,          # timer (age)
        cell_type,
        cell_type,  # initial_cell_type
        0,          # last_division_type
        0,          # nbdiv
        initial_nbdiv, # initial_nbdiv
        true,       # is_alive
        false,      # has_proliferated_this_step
        1           # current_type_index_in_sequence
    )
    return new_cell
end

"""Associates a function to calculate the maximum number of divisions with a cell type."""
function set_max_function!(model::ShapeGrowthModels.CellModel, cell_type::Int64, max_function::Function)
    model.max_cell_divisions_dict[cell_type] = max_function
    #println("Max divisions function defined for cell type $cell_type.")
end

function set_type_sequence!(model, type_sequence::Vector{Int64})
    if hasfield(typeof(model), :type_sequence)
        model.type_sequence = type_sequence
        println("Type sequence defined: $(model.type_sequence)")
    else
        error("The model does not contain a :type_sequence field to store the type sequence.")
    end
end

function create_default_initial_cells(start_coords::Tuple{Int64, Int64} = (50, 50), initial_type::Int64 = 1)
    initial_cell = ShapeGrowthModels.Cell(start_coords, 0, initial_type, initial_type, 0, 0, 0, true, false, 1)
    cells_dict = Dict(start_coords => initial_cell)
    return ShapeGrowthModels.CellSetByCoordinates(cells_dict)
end


const initial_cells_default = create_default_initial_cells()