# src/functions.jl

# NOTE: Types like 'CellModel', 'Cell', 'StromalCell', and functions such as
# 'calculate_max_cell_divisions', 'try_evolution!' are assumed to be defined elsewhere.

# --- High-Level Simulation Functions ---

"""
    run!(model::CellModel; num_steps::Int64)

Executes the cellular dynamics for a specified number of steps.
Encapsulates the call to `cellular_dynamics` and updates the model's state in place.

# Arguments
- `model::CellModel`: The simulation model.
- `num_steps::Int64`: The total number of simulation steps to run.

# Returns
The final step number reached (`final_step`).
"""
function run!(model::CellModel; num_steps::Int64)
    history_result, final_step = cellular_dynamics(
    model, num_steps)

    model.history = history_result
    model.current_time = final_step
    
    return final_step
end

"""
    cellular_dynamics(model::CellModel, num_steps::Int64)

Controls the main simulation loop, advances time, and records the history of the model's state.

# Arguments
- `model::CellModel`: The cellular simulation model.
- `num_steps::Int64`: The total number of steps to simulate.

# Returns
A tuple `(history, final_step)`: the recorded history and the number of steps completed.
"""

function cellular_dynamics(
    model::CellModel,
    num_steps::Int64
)
    # Define the type for history entries for clarity and performance
    history = Vector{NamedTuple{(:tissue_cells, :stromal_tissue_cells), Tuple{Dict{Vector{Int64}, Cell}, Dict{Vector{Int64}, StromalCell}}}}()
    
    # Prepare the initial stromal state for history (deep copy or empty dict if nothing)
    stromal_for_history = isnothing(model.stromal_tissue_cells) ? 
                          Dict{Vector{Int64}, StromalCell}() : 
                          deepcopy(model.stromal_tissue_cells)
    
    # 1. Save the initial state (Step 0)
    push!(history, (tissue_cells = deepcopy(model.tissue_cells), stromal_tissue_cells = stromal_for_history))
    
    # 2. Simulation Loop
    for step in 1:num_steps
        println("\n--- Step $step ---")
        
        initial_cell_count = length(model.tissue_cells) # Snapshot after step (unused)
        
        # Call simulate_step! to modify the model in place.
        simulate_step!(model)
        
        final_cell_count = length(model.tissue_cells)

        # Save the state *after* the simulation step
        stromal_for_history = isnothing(model.stromal_tissue_cells) ? 
                              Dict{Vector{Int64}, StromalCell}() : 
                              deepcopy(model.stromal_tissue_cells)
        
        push!(history, (tissue_cells = deepcopy(model.tissue_cells), stromal_tissue_cells = stromal_for_history))        
        
        model.current_time += 1
    end
    
    if length(history) - 1 == num_steps
       println("Raison de l'arrêt : Nombre maximum d'étapes atteint (", num_steps, ").")
    end

    return history, length(history) - 1
end

"""
    simulate_step!(model::CellModel)

Executes the cell evolution logic for a single time step.
It iterates over cell types based on `model.cell_type_sequence`.

# Arguments
- `model::CellModel`: The model to be modified in place.
"""
function simulate_step!(model::CellModel)
    tissue_cells=model.tissue_cells
    # 1. Reset cell proliferation status
    reset_proliferation_status!(tissue_cells)
    
    # Initialize counters for this step
    tissue_cells_proliferated_this_step = 0
    tissue_cells_differentiated_this_step = 0
    tissue_cells_died_this_step = 0
    tissue_cells_converted_to_stromal = 0
    
    # Dictionary to hold cells requiring differentiation/processing in the next iteration
    cells_to_differentiate_dict= Dict{Vector{Int64}, Cell}()

    # 2. Loop through the cell type sequence to apply evolution logic
    for i in 1:length(model.cell_type_sequence)
        
        # Get the subset of cells corresponding to the current cell type index 'i'
        subtissues = get_indexed_subtissues(model.tissue_cells, model.cell_type_sequence)[i]
        
        # Merge the cells pending differentiation from the previous iteration into the current subset.
        merge!(subtissues, cells_to_differentiate_dict)

        # Run the core evolution (proliferation/differentiation/death) for this subset.
        cells_to_differentiate_dict=proliferation(model, subtissues)
    end    
           
end

#= 
    # Update state for the next step: update timer and reset proliferation status
function update_cell_state!(next_tissue_cells_::Dict{Vector{Int64}, Cell})
    for cell in values(next_tissue_cells_dict)
        cell.is_alive && (cell.timer += 1)
    end

    return 
end =#


"""
    reset_proliferation_status!(tissue_cells::Dict{Vector{Int64}, Cell})

Resets the proliferation status (`has_proliferated_this_step`) and cell type 
for all `tissue_cells` at the beginning of a step.
"""
function reset_proliferation_status!(tissue_cells::Dict{Vector{Int64}, Cell})
    for cell in values(tissue_cells)
        cell.has_proliferated_this_step = false
        cell.cell_type = cell.last_division_type 
    end
end


"""
    create_new_cell(model::CellModel, cell::Cell, new_coordinates::Vector{Int64})

Creates a new `Cell` instance (daughter cell) based on the state of the mother cell (`cell`).

# Arguments
- `model::CellModel`: The model (needed for dynamic division calculation).
- `cell::Cell`: The mother cell.
- `new_coordinates::Vector{Int64}`: The coordinates of the new cell.

# Returns
The new `Cell` instance.
"""
function create_new_cell(model::CellModel, cell::Cell, new_coordinates::Vector{Int64})
    # Placeholder cell for calculate_max_cell_divisions
    new_cell = Cell(
            new_coordinates, 
            0, 
            cell.cell_type, 
            cell.initial_cell_type, 
            cell.last_division_type, 
            cell.nbdiv, 
            cell.max_cell_divisions, 
            true, 
            true, 
            cell.current_type_index_in_sequence
        )
        
        new_cell.max_cell_divisions=calculate_max_cell_divisions(model, new_cell)

    return new_cell
end


"""
    get_indexed_subtissues(tissue_cells::Dict{Vector{Int64}, Cell}, cell_type_sequence::Vector{Symbol})

Separates the main `tissue_cells` dictionary into sub-dictionaries indexed by
the cell's position (1 to N) in the `cell_type_sequence`.

# Arguments
- `tissue_cells`: The dictionary of all cells (coordinates => Cell).
- `cell_type_sequence`: The ordered sequence of cell types.

# Returns
`Dict{Int64, Dict{Vector{Int64}, Cell}}`: Dictionary of indexed sub-tissues.
"""
function get_indexed_subtissues(
    tissue_cells::Dict{Vector{Int64}, Cell}, # Le dictionnaire de toutes les cellules (coordonnées => Cell)
    cell_type_sequence::Vector{Symbol}       # La séquence ordonnée des types de cellules (pour la validation des indices)
    )

    indexed_subtissues = Dict{Int64, Dict{Vector{Int64}, Cell}}()

    # 1. Initialize a dictionary for each index
    num_types = length(cell_type_sequence)
    for i in 1:num_types
        # L'indice 'i' de 1 à N est la clé principale
        indexed_subtissues[i] = Dict{Vector{Int64}, Cell}()
    end

    # 2. Iterate through all cells and sort them by index
    for (coordinates, cell) in tissue_cells
        index = cell.current_type_index_in_sequence
        
        # 3. Validation and insertion
        if 1 <= index <= num_types
            
            # 5. Ajouter la cellule au sous-tissu correspondant à son index
            indexed_subtissues[index][coordinates] = cell
        else
            @warn "Cellule aux coordonnées $(coordinates) a un index hors limites ($index). Ignorée."
        end
    end
    
    return indexed_subtissues
end

"""
    difference_dictionnaires(ens1::Dict{Vector{Int64}, Cell}, ens2::Dict{Vector{Int64}, Cell})

Calculates the set difference based on keys (coordinates).
Returns cells present in `ens1` but absent from `ens2`.

# Arguments
- `ens1`: The dictionary to subtract from.
- `ens2`: The dictionary to subtract.

# Returns
The resulting difference dictionary.
"""
function difference_dictionnaires(
    ens1::Dict{Vector{Int64}, Cell},
    ens2::Dict{Vector{Int64}, Cell}
    )
    difference = Dict{Vector{Int64}, Cell}()
    for (coords, cell) in ens1
        # If the key is NOT found in ens2, add it to the result
        if !haskey(ens2, coords)
            difference[coords] = cell
        end
    end

    return difference
end

"""
    proliferation(model::CellModel, tissue_cells::Dict{Vector{Int64}, Cell})::Dict{Vector{Int64}, Cell}

Applies the evolution logic (`try_evolution!`) to a subset of cells.
Updates `model.tissue_cells` in place.

# Arguments
- `model::CellModel`: The simulation model.
- `tissue_cells`: The subset of cells to process in this step.

# Returns
A dictionary of cells that need to be differentiated and processed in the next step/iteration.
"""
function proliferation(model::CellModel, tissue_cells::Dict{Vector{Int64}, Cell})::Dict{Vector{Int64}, Cell}
    # These dictionaries are initialized but unused in the body's current logic.
    new_cells = Dict{Vector{Int64}, Cell}()
    # apoptosis_cells = Dict{Vector{Int64}, Cell}()
    
    cells_to_differentiate = Dict{Vector{Int64}, Cell}()    
    
    for cell in values(tissue_cells)
        # Check if the cell is alive, not nil, and hasn't proliferated this step
        if !isnothing(cell) && cell.is_alive && !cell.has_proliferated_this_step 
            
            # Attempt evolution (proliferation, death, or differentiation)
            evolution = try_evolution!(model, cell)
            
            # evolution is expected to be a tuple (new_cells, dead_cells, differentiated_cells, success_bool)
            
            # Check the success boolean (evolution[4])
            if evolution[4]
                # If successful (implying proliferation), merge new cells into the global model.
                merge!(model.tissue_cells , evolution[1])
            else
                # Otherwise, merge the cells marked for differentiation into the temporary dictionary.
                merge!(cells_to_differentiate, evolution[3])
            end  

        end
    end   
    return cells_to_differentiate
end
