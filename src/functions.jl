# src/functions.jl

# create_directions_dict utilise maintenant la constante Dim

#= function create_directions_dict(directions_vector::Dict{String, Vector{Int64}}, nb_dirs::Int64)
    directions = Dict{String, Dict{Int64, Int64}}()
    for (type, dirs) in directions_vector
        temp_dict = Dict{Int64, Int64}()
        for i in 0:nb_dirs-1
            temp_dict[i] = dirs[i+1]
        end
        directions[type] = temp_dict
    end
    return directions
end =#

function create_directions_dict(cell_directions::Dict{Symbol, Vector{Int64}}, Dim)
    # Direction cases for 2D
    cases_2d = Dict(
        1 => [[0, 0]],   # Neutral
        2 => [[0, -1]],  # West
        3 => [[-1, 0]],  # North
        4 => [[0, 1]],   # East
        5 => [[1, 0]],   # South
    )
    # Direction cases for 3D
    cases_3d = Dict(
        1 => [[0, 0, 0]],   # Neutral
        2 => [[0, -1, 0]],  # West
        3 => [[-1, 0, 0]],  # North
        4 => [[0, 1, 0]],   # East
        5 => [[1, 0, 0]],   # South
        6 => [[0, 0, 1]],   # Forward
        7 => [[0, 0, -1]],  # Backward
    )

    cases_to_use = Dim == 2 ? cases_2d : cases_3d

    result_dict = Dict{Symbol, Vector{Vector{Int64}}}() 
    
    for (cell_type, directions) in cell_directions
        new_dirs = Vector{Vector{Int64}}()
        for direction_int in directions
            if haskey(cases_to_use, direction_int) && direction_int != 0
                
                append!(new_dirs, cases_to_use[direction_int])
            else
                # Returns a vector of zeros of the correct dimension
                push!(new_dirs, zeros(Int64, Dim))
            end
        end
        result_dict[cell_type] = new_dirs
    end
    println("Processed directions for Dim=$Dim: ", result_dict)
    return result_dict
end


# The run! function encapsulates the call to cellular_dynamics

function run!(model::CellModel; num_steps::Int64)
    history_result, final_step = cellular_dynamics(
        model,num_steps)
    model.history = history_result
    model.current_time = final_step
    return final_step
end

# La fonction cellular_dynamics prend le modèle en paramètre
function cellular_dynamics(
    model::CellModel,
    num_steps::Int64
)
    history=[]
    grid_size= model.grid_size
    cell_type_sequence = model.cell_type_sequence
    cell_data = model.cell_data
    #model.stromal_cells = deepcopy(my_initial_stromal_dict)
    stromal_for_history = isnothing(model.stromal_cells) ? 
                          Dict{Vector{Int64}, StromalCell}() : 
                          deepcopy(model.stromal_cells)
    push!(history, (cells = deepcopy(model.cells), stromal_cells = stromal_for_history))
    
     
          
    current_cells = deepcopy(model.cells)
    println("current_cells: ",current_cells )
    for step in 1:num_steps
        println("\n--- Step $step ---")
        println("Number of cells at start of step: ", length(current_cells))
        # simulate_step! reçoit le modèle
        new_cells = simulate_step!(
            model,
            current_cells
        )
        
        stromal_for_history = isnothing(model.stromal_cells) ? 
                          Dict{Vector{Int64}, StromalCell}() : 
                          deepcopy(model.stromal_cells)

        # CHANGE 3: Refer to the local `history` variable when pushing.
        push!(history, (
            cells = deepcopy(new_cells), 
            stromal_cells = stromal_for_history
        ))

        if Set(keys(current_cells)) == Set(keys(new_cells)) 
            println("\nRaison de l'arrêt : Les coordonnées des cellules se sont stabilisées.")
            break
        end 
        
        current_cells = new_cells
        model.current_time += 1
    end

    if length(history) - 1 == num_steps # CHANGE 4: Check the length of the local `history` variable.
        println("Raison de l'arrêt : Nombre maximum d'étapes atteint (", num_steps, ").")
    end

    # history contains the full record of both cell types at each step
    return history, length(history) - 1 # CHANGE 5: Return the local `history` variable.
end




# simulate_step! reçoit le modèle et a les bons types de dictionnaires
function simulate_step!(
    model::CellModel,
    current_cells::Dict{Vector{Int64}, Cell}
)
    # The new dictionary to hold the cells after this step.
    #println("\n--- Démarrage de l'étape ---")
    #println("initial_stromal_cells", model.stromal_cells)
    reset_proliferation_status!(current_cells)
    cell_type_sequence = model.cell_type_sequence
    grid_size = model.grid_size
    
    next_cells_dict = deepcopy(current_cells)

    # Initialize counters for this step
    cells_proliferated_this_step = 0
    cells_differentiated_this_step = 0
    cells_died_this_step = 0
    cells_converted_to_stromal = 0

    # Pre-calculate directions once for the entire step
    raw_int_directions = create_directions(model.cell_data)
    #processed_vector_directions = create_directions_dict(raw_int_directions)
    processed_vector_directions = create_directions_dict(raw_int_directions, length(grid_size))

    # Main unified loop over all cells
    # 1. Phase de Prolifération
for cell_type in cell_type_sequence
        cells_of_type_dict = Dict{Vector{Int64}, Cell}(
            coord => cell
            for (coord, cell) in current_cells
        
            if cell.is_alive && cell.cell_type == cell_type
        )

        # Get directions for the current cell type
        cell_directions_int = raw_int_directions[cell_type]
        directions = processed_vector_directions[cell_type]

       for (coord, cell) in cells_of_type_dict
            
            max_cell_division_val = max(calculate_max_divisions(model, cell), model.cell_data[cell_type]["max_cell_division"])
            # Call attempt_proliferation! with the correct arguments
            action_occurred, proliferated_count, differentiated_count, apoptosis_count, converted_to_stromal_count = attempt_proliferation!(
                model,
                next_cells_dict,
                current_cells,
                cell,
                cell_directions_int,
                directions,
                max_cell_division_val
        )

        cells_proliferated_this_step += proliferated_count
        cells_differentiated_this_step += differentiated_count
        cells_died_this_step += apoptosis_count
        cells_converted_to_stromal += converted_to_stromal_count
       end
    end    
    # 2. Phase de Différenciation
    for cell_type in cell_type_sequence
        cells_for_differentiation = [
            cell for cell in values(current_cells)
            if cell.is_alive && cell.cell_type == cell_type && !cell.has_proliferated_this_step
        ]

        for cell in cells_for_differentiation
            if haskey(next_cells_dict, cell.coordinates)
                current_state_of_cell = next_cells_dict[cell.coordinates]
                if !isnothing(current_state_of_cell) && current_state_of_cell.is_alive && !current_state_of_cell.has_proliferated_this_step
                    max_cell_division_for_diff_val = calculate_max_divisions(model, current_state_of_cell)
                    
                    # Call try_differentiate! with all 7 expected arguments and correct types
                    if try_differentiate!(
                        model,
                        next_cells_dict,
                        current_cells,
                        cell_type_sequence,
                        processed_vector_directions,          # 4th arg: proliferation_directions (Dict{Int64, Vector{NTuple{Dim, Int64}}})
                        max_cell_division_for_diff_val,      # 5th arg: max_cell_division (Float64 from Real)
                        grid_size,                           # 6th arg: grid_size (NTuple{Dim, Int64})
                        cell_type                            # 7th arg: cell_type_to_process (Int64)
                    )
                        cells_differentiated_this_step += 1
                        cells_proliferated_this_step += 1 # Check this: Differentiation also counts as proliferation? (Keep if intended)
                    end
                end
            end
        end
    end

    # 3. Mettre à jour les timers des cellules vivantes et construire le Dictionnaire final
    final_next_cells_dict = Dict{Vector{Int64}, Cell}()
    for (coord, cell) in next_cells_dict
        if cell.is_alive
            cell.timer += 1
            final_next_cells_dict[coord] = cell
        end
    end    
    return final_next_cells_dict
end









    # Update state for the next step: update timer and reset proliferation status
function update_cell_state!(next_cells_dict::Dict{Vector{Int64}, Cell})
        for cell in values(next_cells_dict)
        cell.is_alive && (cell.timer += 1)
    end

    return next_cells_dict
end


"""Resets the proliferation status for all cells at the beginning of a step."""
function reset_proliferation_status!(current_cells::Dict{Vector{Int64}, Cell})
    for cell in values(current_cells)
        cell.has_proliferated_this_step = false
    end
end
"""
Returns `Dict{Int64, Vector{Int64}}`: A dictionary where keys are cell types and
values are the vectors of proliferation directions.
"""

function create_directions(cell_data::Dict{Symbol, Dict{String, Any}})
    directions = Dict{Symbol, Vector{Int64}}()
    for (type_id, data) in cell_data
        directions[type_id] = data["directions"]
    end
    return directions
end
#= function create_directions(cell_data::Dict{Symbol, Dict{String, Any}}) 
    directions = Dict{Int64, Vector{Int64}}()
    for (cell_type, data) in cell_data
        # Ensure 'data' is indeed a Dict{String, Any} and has "directions" key
        if haskey(data, "directions") && isa(data["directions"], Vector{Int64})
            directions[cell_type] = data["directions"]
        else
            # Handle cases where "directions" might be missing or wrong type
            # For example, assign an empty vector or log a warning
            println("Warning: 'directions' not found or is of incorrect type for cell_type $cell_type in cell_data. Assigning empty vector.")
            directions[cell_type] = Int64[] # Assign an empty vector
        end
    end
    return directions
end =#


function create_new_cell(model::CellModel, coordinates::Vector{Int64}, cell_type::Symbol)
    # Placeholder cell for calculate_max_divisions
    temp_cell = Cell(coordinates, 0, cell_type, cell_type, 0, 0, 0, true, false, 1)
    max_divisions = calculate_max_divisions(model, temp_cell)
    
    new_cell = Cell(
        coordinates,
        0,
        cell_type,
        cell_type,
        0,
        0,
        max_divisions,
        true,
        false,
        1
    )
    return new_cell
end
