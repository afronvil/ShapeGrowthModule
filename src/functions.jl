using ColorSchemes
using Plots
# --- Cellular Dynamics Functions ---

"""Attempts to make a cell proliferate in a given direction."""
function try_proliferate!(next_cells, parent_cell, dir, max_div, grid_size)
    if parent_cell.is_alive && parent_cell.nbdiv < max_div && !parent_cell.has_proliferated_this_step
        new_coords = parent_cell.coordinates .+ dir
        if checkbounds(Bool, zeros(Int64, grid_size...), new_coords...) && !haskey(next_cells, new_coords)
            parent_cell.last_division_type = parent_cell.cell_type
            parent_cell.nbdiv += 1
            next_index_in_sequence = parent_cell.current_type_index_in_sequence
            new_cell = ShapeGrowthModels.Cell(new_coords, 0, parent_cell.cell_type, parent_cell.cell_type, parent_cell.last_division_type, parent_cell.nbdiv, parent_cell.nbdiv, true, false, next_index_in_sequence)
            parent_cell.has_proliferated_this_step = true
            new_cell.has_proliferated_this_step = true
            next_cells[parent_cell.coordinates] = parent_cell
            next_cells[new_coords] = new_cell
            return true
        end
    end
    return false
end

"""Attempts to make a cell proliferate in all possible directions for its type."""
function attempt_proliferation!(next_cells, current_cells, cell, directions, max_cell_division, grid_size)
    if cell.is_alive && !cell.has_proliferated_this_step && haskey(directions, cell.cell_type)
        for dir in directions[cell.cell_type]
            if try_proliferate!(next_cells, cell, dir, max_cell_division, grid_size) && cell.nbdiv < max_cell_division
                cell.has_proliferated_this_step = true
                return true
            end
        end
    end
    return cell.has_proliferated_this_step
end



"""Performs the differentiation of a cell to a new type."""
function differentiation!(next_cells, cell::ShapeGrowthModels.Cell, new_type::Int64)
    if cell.is_alive
        cell.cell_type = new_type
        cell.nbdiv = 0
        next_cells[cell.coordinates] = cell
    end
end

"""Attempts to differentiate cells and then make them proliferate."""
function try_differentiate!(next_cells, current_cells, cell_type_sequence::Vector{Int64}, proliferation_directions::Dict{Int64, Vector{Tuple{Int64, Int64}}}, max_cell_division, grid_size::Tuple{Int64, Int64}, cell_type_to_process::Int64)
    cells_to_differentiate = [cell for cell in values(current_cells.cells) if cell.is_alive && cell.cell_type == cell_type_to_process && !cell.has_proliferated_this_step]
    processed_cells = Set{Tuple{Int64, Int64}}() # Track successfully processed cells

    for cell in cells_to_differentiate
        if cell.coordinates in processed_cells
            continue # Skip if already differentiated and proliferated
        end

        original_state = deepcopy(cell)
        differentiation_attempted = false
        proliferation_succeeded_once = false

        start_index = isnothing(cell.current_type_index_in_sequence) ? 1 : cell.current_type_index_in_sequence

        for i in start_index+1:length(cell_type_sequence)
            next_index_in_sequence = i
            next_possible_type = cell_type_sequence[i]
            differentiation!(next_cells, cell, next_possible_type)
            differentiation_attempted = true

            if haskey(proliferation_directions, next_possible_type)
                temp_cell = deepcopy(next_cells[cell.coordinates])
                proliferated = false
                for dir in proliferation_directions[next_possible_type]
                    temp_cell.current_type_index_in_sequence = next_index_in_sequence
                    proliferated = try_proliferate!(next_cells, temp_cell, dir, max_cell_division, grid_size)
                    if proliferated
                        proliferation_succeeded_once = true
                        temp_cell.current_type_index_in_sequence = next_index_in_sequence
                        next_cells[cell.coordinates] = temp_cell
                        push!(processed_cells, cell.coordinates) # Mark as processed
                        cell.cell_type = temp_cell.cell_type
                        cell.nbdiv = temp_cell.nbdiv
                        cell.has_proliferated_this_step = true
                        cell.current_type_index_in_sequence = temp_cell.current_type_index_in_sequence # Update index
                        break
                    end
                end
                if proliferation_succeeded_once
                    break # Proliferation successful, move to the next cell
                else
                    # Proliferation failed for this type, restore original state for next attempt
                    next_cells[cell.coordinates] = original_state
                    cell.cell_type = original_state.cell_type
                    cell.nbdiv = original_state.nbdiv
                    # Do NOT update index here as differentiation wasn't "validated" by proliferation
                end
            else
                next_cells[cell.coordinates] = original_state
                cell.cell_type = original_state.cell_type
                cell.nbdiv = original_state.nbdiv
                # Do NOT update index here as differentiation wasn't "validated" by proliferation
            end
        end

        if !proliferation_succeeded_once && differentiation_attempted && haskey(next_cells, cell.coordinates)
            next_cells[cell.coordinates] = original_state
            next_cells[cell.coordinates].is_alive = false
        elseif proliferation_succeeded_once
            break
        elseif !differentiation_attempted
            # Cell did not attempt differentiation
        end
    end
end

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
    next_cells = deepcopy(current_cells.cells)
    for cell_type in cell_type_sequence
        cells_of_type = [cell for cell in values(current_cells.cells) if cell.is_alive && cell.cell_type == cell_type]
        for cell in cells_of_type
            max_cell_division = calculate_max_divisions(model, cell)
            attempt_proliferation!(next_cells, current_cells, cell, proliferation_directions, max_cell_division, grid_size)
        end
        for cell in cells_of_type
            if cell.is_alive && !cell.has_proliferated_this_step
                max_cell_division = calculate_max_divisions(model, cell)
                try_differentiate!(next_cells, current_cells, cell_type_sequence, proliferation_directions, max_cell_division, grid_size, cell_type)
            end
        end
    end
    update_cell_state!(next_cells)
    return ShapeGrowthModels.CellSetByCoordinates(next_cells)
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

function create_directions_dict(cell_directions::Dict{Int64, Vector{Int64}}, cases::Dict{Int64, Vector{Tuple{Int64, Int64}}})
    result_dict = Dict{Int64, Vector{Tuple{Int64, Int64}}}()
    for (cell_type, directions) in cell_directions
        result_dict[cell_type] = directions_to_tuples(directions, cases)
    end
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

function cellular_dynamics(model::ShapeGrowthModels.CellModel, initial_cells::ShapeGrowthModels.CellSetByCoordinates, num_steps::Int64, grid_size::Tuple{Int64, Int64}, cell_type_sequence::Vector{Int64} = [1, 2, 3, 1], xml_file::String = "cellTypes.xml")
    cell_data = ShapeGrowthModels.load_cell_data(xml_file, cell_type_sequence)
    history = [deepcopy(initial_cells)]
    current_cells = ShapeGrowthModels.CellSetByCoordinates(Dict{Tuple{Int64, Int64}, ShapeGrowthModels.Cell}())
    cell_directions = create_directions(cell_data)
    # Assuming 'cases' is defined elsewhere and accessible
    proliferation_directions = create_directions_dict(cell_directions, cases)
    new_cells = deepcopy(initial_cells)
    step = 1

    while !(get_cell_coordinates(current_cells) == get_cell_coordinates(new_cells)) && step < num_steps
        current_cells = new_cells
        new_cells = simulate_step!(model, current_cells, proliferation_directions, cell_type_sequence, grid_size)
        push!(history, deepcopy(new_cells)) # Keep deepcopy for history
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
        model.type_sequence, # Cell type sequence from the model
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
    println("Max divisions function defined for cell type $cell_type.")
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