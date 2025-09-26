# src/functions.jl

# create_directions_dict utilise maintenant la constante Dim

# The run! function encapsulates the call to cellular_dynamics

function run!(model::CellModel; num_steps::Int64)
    
    history_result, final_step = cellular_dynamics(
    model, num_steps)
    #=#println ("history_result", history_result)
   #println(" ") =#
    model.history = history_result
    model.current_time = final_step
    
    return final_step
end

# La fonction cellular_dynamics prend le modèle en paramètre
function cellular_dynamics(
    model::CellModel,
    num_steps::Int64
)
    # The history vector will store snapshots of the model state
    history = Vector{NamedTuple{(:tissue_cells, :stromal_tissue_cells), Tuple{Dict{Vector{Int64}, Cell}, Dict{Vector{Int64}, StromalCell}}}}()
    
    # Save the initial state to history
    stromal_for_history = isnothing(model.stromal_tissue_cells) ? 
                          Dict{Vector{Int64}, StromalCell}() : 
                          deepcopy(model.stromal_tissue_cells)
    push!(history, (tissue_cells = deepcopy(model.tissue_cells), stromal_tissue_cells = stromal_for_history))
    
    for step in 1:num_steps
       #println("\n--- Step $step ---")
        
        initial_cell_count = length(model.tissue_cells)
        
        # Call simulate_step! to modify the model in place.
        # Do not reassign the result to `model`.
        simulate_step!(model)
        
        final_cell_count = length(model.tissue_cells)

        # Save the state *after* the simulation step
        stromal_for_history = isnothing(model.stromal_tissue_cells) ? 
                              Dict{Vector{Int64}, StromalCell}() : 
                              deepcopy(model.stromal_tissue_cells)
        push!(history, (tissue_cells = deepcopy(model.tissue_cells), stromal_tissue_cells = stromal_for_history))

        #= if final_cell_count == initial_cell_count
           #println("\nRaison de l'arrêt : Les coordonnées des cellules se sont stabilisées.")
            break
        end  =#
        
        model.current_time += 1
    end
    
    if length(history) - 1 == num_steps
       #println("Raison de l'arrêt : Nombre maximum d'étapes atteint (", num_steps, ").")
    end

    return history, length(history) - 1
end

# simulate_step! reçoit le modèle et a les bons types de dictionnaires
function simulate_step!(
    model::CellModel)
    tissue_cells=model.tissue_cells
    reset_proliferation_status!(tissue_cells)
    next_tissue_cells_dict = deepcopy(tissue_cells)
    
    # Initialize counters for this step
    tissue_cells_proliferated_this_step = 0
    tissue_cells_differentiated_this_step = 0
    tissue_cells_died_this_step = 0
    tissue_cells_converted_to_stromal = 0

    
    
    
    for cell_type in model.cell_type_sequence
       #println(" ")
       #println("cell_type : ",cell_type)
        cells_for_differentiation = Dict(
        cell.coordinates => cell 
        for cell in values(tissue_cells)
            if cell.is_alive  && cell.cell_type == cell_type && !cell.has_proliferated_this_step
        )

        
        #println("cells_for_differentiation : ",cells_for_differentiation)
        for cell in values(cells_for_differentiation)
           #println("cell.coordinates : ",cell.coordinates)
            if haskey(tissue_cells, cell.coordinates)
                #cell = tissue_cells[cell.coordinates]
                
               
                if !isnothing(cell) && cell.is_alive && !cell.has_proliferated_this_step
                   #println("cell.nbdiv tissue_cells : ", cell.nbdiv)

                    if try_differentiate!(
                            model, cell
                        )
                       #println("cell.nbdiv si diff ok : ", cell.nbdiv)
                        tissue_cells_differentiated_this_step += 1
                        tissue_cells_proliferated_this_step += 1
                    end
                end
            end
             
       #println("cell.nbdiv fin step : ", cell.nbdiv)   
        end    
    end
    # 3. Mettre à jour les timers des cellules vivantes et construire le Dictionnaire final
#=     final_next_tissue_cells_dict = Dict{Vector{Int64}, Cell}()
    for (coord, cell) in tissue_cells
        if cell.is_alive
            cell.timer += 1
            final_next_tissue_cells_dict[coord] = cell
        end
    end  =#   
    #return final_next_tissue_cells_dict
    #println("Proliferate tissue_cells fin : ", tissue_cells)
    
    return model
end


    # Update state for the next step: update timer and reset proliferation status
function update_cell_state!(next_tissue_cells_dict::Dict{Vector{Int64}, Cell})
        for cell in values(next_tissue_cells_dict)
        cell.is_alive && (cell.timer += 1)
    end

    return 
end


"""Resets the proliferation status for all tissue_cells at the beginning of a step."""
function reset_proliferation_status!(tissue_cells::Dict{Vector{Int64}, Cell})
    for cell in values(tissue_cells)
        cell.has_proliferated_this_step = false
        cell.cell_type = cell.last_division_type 
        #cell.cell_type = cell.last_division_type 
    end
end
"""
Returns `Dict{Int64, Vector{Int64}}`: A dictionary where keys are cell types and
values are the vectors of proliferation directions.
"""


function create_new_cell(cell::Cell, new_coordinates::Vector{Int64})
    # Placeholder cell for calculate_max_cell_divisions
    
    
    new_cell = Cell(
            new_coordinates, 
            0, 
            cell.cell_type, 
            cell.initial_cell_type, 
            cell.last_division_type, 
            cell.nbdiv, 
            cell.nbdiv, 
            true, 
            true, 
            cell.current_type_index_in_sequence
        )
    return new_cell
end
