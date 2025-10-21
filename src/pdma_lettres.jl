# src/pdma.jl
# --- Cell Evolution and Dynamics Functions ---
"""
    try_evolution!(model::CellModel, cell::Cell)

Attempts to evolve a cell through proliferation, differentiation, or apoptosis based on 
the sequence of cell types and the rules defined in `proliferation_type_cell`.

# Arguments
- `model::CellModel`: The simulation model.
- `cell::Cell`: The cell attempting to evolve.

# Returns
A tuple: `(new_cells, apoptosis_cells, differentiated_cells, proliferation_this_step::Bool)`
"""

function try_evolution!(model::CellModel, cell::Cell) 
    proliferation_this_step = false
    original_cell = deepcopy(cell)
    
    # Dictionaries to collect results for the history step
    new_cell = Dict{Vector{Int64}, Cell}()
    apoptosis_cell = Dict{Vector{Int64}, Cell}()
    differentiate_cell = Dict{Vector{Int64}, Cell}()
    
    # Loop from the cell's current type index to the end of the sequence
    for i in cell.current_type_index_in_sequence:length(model.cell_type_sequence)
        type_cellulaire = model.cell_type_sequence[i]
        
        # Get the result of the evolution attempt (Action, Resulting Cell)
        PDMA = proliferation_type_cell(
            model,
            cell,
            i
            )
            
        action = PDMA[1]
        result_cell = PDMA[2]
        
        # Process the result and break the loop on any definitive action
        if action == :proliferation
            new_cell[result_cell.coordinates] = result_cell
            proliferation_this_step = true
            break
            
        elseif action == :differentiation
            differentiate_cell[result_cell.coordinates] = result_cell
            proliferation_this_step = false 
            break 
            
        elseif action == :apoptosis
            apoptosis_cell[result_cell.coordinates] = result_cell
            # NOTE: Original logic sets proliferation_this_step = true for apoptosis
            proliferation_this_step = true 
            break
            
        else # Action is :quiescence or unhandled state
            _restore_cell_state!(cell, original_cell) 
            proliferation_this_step = false
            cell.cell_type = cell.last_division_type # Overrides restoration? (Original logic preserved)
            break 
        end
    end
    
    return new_cell, apoptosis_cell, differentiate_cell, proliferation_this_step
end

"""
    try_proliferate!(model::CellModel, cell::Cell, dir_symbol::Symbol)

Attempts a proliferation event for a cell in a specific direction (`dir_symbol`).
Modifies `cell` in place if successful.

# Arguments
- `model::CellModel`: The simulation model.
- `cell::Cell`: The cell attempting to proliferate.
- `dir_symbol::Symbol`: The intended direction of proliferation.

# Returns
A tuple: `(success::Bool, new_cell::Cell)` where `success` is `cell.has_proliferated_this_step`.
"""
function try_proliferate!(model::CellModel, cell::Cell, dir_symbol::Symbol,)    
    # Check pre-conditions for proliferation
    if (!cell.is_alive 
        || cell.nbdiv >= cell.max_cell_divisions 
        || cell.has_proliferated_this_step)
        return false, cell # Return false and the original cell
    end 
    
    new_cell = cell # Placeholder, will be replaced by the daughter cell if successful
    
    # 1. Determine new coordinates
    dir_vector = create_directions_dict(dir_symbol, length(model.grid_size))
    new_coordinates = cell.coordinates .+ dir_vector[dir_symbol][1]
    
    # 2. Check if the new coordinates are within bounds
    is_in_bounds = all(1 <= new_coordinates[i] <= model.grid_size[i] for i in eachindex(new_coordinates))
    
    # 3. PROLIFERATION check (in bounds AND empty spot)
    if is_in_bounds && !haskey(model.tissue_cells, new_coordinates)
        
        # Update mother cell state
        cell.last_division_type = cell.cell_type
        cell.initial_cell_type = cell.cell_type 
        cell.nbdiv += 1
        cell.has_proliferated_this_step = true
        
        # Create and configure the daughter cell
        new_cell = create_new_cell(model, cell, new_coordinates)  
        new_cell.max_cell_divisions = calculate_max_cell_divisions(model, new_cell)
        
        # NOTE: The original code does not insert the new cell into model.tissue_cells here.
    end    
    
    # Return the status and the daughter cell (or the mother cell if no proliferation occurred)
    return cell.has_proliferated_this_step, new_cell
end

"""
    _restore_cell_state!(cell::Cell, original_cell::Cell) 

Restores specific fields of `cell` from a saved state (`original_cell`).

# Arguments
- `cell::Cell`: The cell to modify.
- `original_cell::Cell`: The cell containing the state to restore.

# Returns
The modified `cell`.
"""
function _restore_cell_state!(cell::Cell, original_cell::Cell) 
    cell.nbdiv = original_cell.nbdiv 
    cell.current_type_index_in_sequence = original_cell.current_type_index_in_sequence
    cell.cell_type = original_cell.cell_type
    cell.last_division_type = original_cell.last_division_type
    return cell
end

"""
    proliferation_type_cell(model::CellModel, cell::Cell, type_cellulaire::Symbol, i::Int64)

Determines the evolution of a cell based on its current `type_cellulaire` 
and the instructions encoded within the symbol's string representation.

# Arguments
- `model::CellModel`: The simulation model.
- `cell::Cell`: The cell being evaluated.
- `type_cellulaire::Symbol`: The current cell type being processed (from the sequence).
- `i::Int64`: The index of the current cell type in the sequence.

# Returns
A tuple `(action::Symbol, result_cell::Cell)`.
"""
function proliferation_type_cell(
    model::CellModel,
    cell::Cell,
    i::Int64
    )::Tuple{Symbol, Cell}
    
    # Default result is quiescence (no change)
    evolution_result = (:quiescence, cell) 
    type_cellulaire = model.cell_type_sequence[i]
    original_cell = deepcopy(cell) 
    direction_string = string(type_cellulaire)
    
    # Instructions are split from the cell type name (e.g., :Stem_A_P -> ["Stem", "A", "P"])
    instructions = split(direction_string, '_')
    
    for dir_char in instructions 
        
        dir_symbol = Symbol(dir_char)
        
        # --- APOTOSIS CHECK (Instruction "A") ---
        if dir_char == "A" && cell.nbdiv < cell.max_cell_divisions
            evolution_result = (:apoptosis, cell)
            cell.has_proliferated_this_step = true # NOTE: Original logic sets this to true for apoptosis
            break
            
        else  
            # --- PROLIFERATION CHECK (Other instructions) ---
            try_proliferate = try_proliferate!(model, cell, dir_symbol)
            
            if try_proliferate[1] # Proliferation was successful
                new_cell = try_proliferate[2]
                evolution_result = (:proliferation, new_cell)
                cell.has_proliferated_this_step = true
                break
                
            elseif i < length(model.cell_type_sequence) # Proliferation failed, check for differentiation
                                
                evolution_result = (:differentiation, cell)  
                next_diff_type = model.cell_type_sequence[i+1]
                
                # Apply differentiation in place
                differentiation!(model, cell, next_diff_type)            
                
            end
        
        end
        
    end
    
    return evolution_result # Return the assigned variable
end


"""
    differentiation!(model::CellModel, cell::Cell, new_type::Symbol) 

Performs the differentiation of a cell to a `new_type`.
Resets `nbdiv` and recalculates `max_cell_divisions`.

# Arguments
- `model::CellModel`: The simulation model.
- `cell::Cell`: The cell undergoing differentiation.
- `new_type::Symbol`: The cell type to differentiate into.
"""
function differentiation!(model::CellModel, cell::Cell, new_type::Symbol) 
    if cell.is_alive
        cell.cell_type = new_type
        cell.current_type_index_in_sequence += 1
        cell.max_cell_divisions = calculate_max_cell_divisions(model, cell)
        cell.nbdiv = 0
    end
end

"""
    apoptosis!(tissue_cells::Dict{Vector{Int64}, Cell}, cell::Cell)

Removes a cell from the `tissue_cells` dictionary if it is alive and present.

# Arguments
- `tissue_cells`: The dictionary of all tissue cells.
- `cell::Cell`: The cell to remove.

# Returns
`true` if the cell was deleted, `false` otherwise.
"""
function apoptosis!(tissue_cells::Dict{Vector{Int64}, Cell}, cell::Cell)
    if cell.is_alive && haskey(tissue_cells, cell.coordinates)
        delete!(tissue_cells, cell.coordinates)
        return true
    end
    return false
end

# ----------------------------------------------------------------------
# 2. Fonction de Migration (Reprise de notre discussion précédente)
# ----------------------------------------------------------------------
function try_migrate!(
    model::CellModel,
    tissue_cells_to_migrate::Dict{Vector{Int64}, Cell}, 
    v::Vector{Int64}
)
    migrated_cells = Dict{Vector{Int64}, Cell}()
    old_coordinates_to_delete = Vector{Vector{Int64}}()

    # On itère sur une copie des clés pour éviter les erreurs de modification en cours de boucle
    for old_coords in keys(tissue_cells_to_migrate)
        # S'assurer que la cellule existe toujours dans le dictionnaire global
        !haskey(model.tissue_cells, old_coords) && continue
        
        cell = model.tissue_cells[old_coords]
        new_coords = old_coords .+ v
        
        # 1. Vérification des limites de la grille
        is_in_bounds = all(1 <= new_coords[i] <= model.grid_size[i] for i in eachindex(new_coords))
        
        # 2. Vérification que la nouvelle position est vide
        is_spot_empty = !haskey(model.tissue_cells, new_coords)
       
        if is_in_bounds && is_spot_empty
            # Migration réussie :
            
            # A. Met à jour les coordonnées de l'objet Cell
            cell.coordinates = new_coords
            
            # B. Ajoute la cellule au dictionnaire des cellules migrées
            migrated_cells[new_coords] = cell
            
            # C. Marque l'ancienne position pour la suppression
            push!(old_coordinates_to_delete, old_coords)
        end
    end

    # Mise à jour du dictionnaire global (Modification en place)
    
    # 1. Ajoute les cellules migrées à leurs nouvelles coordonnées
    merge!(model.tissue_cells, migrated_cells)
    
    # 2. Supprime les cellules de leurs anciennes coordonnées
    for old_coords in old_coordinates_to_delete
        delete!(model.tissue_cells, old_coords)
    end
    
    return migrated_cells
end