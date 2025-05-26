
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


"""Attempts to migrate a cell to an adjacent empty location."""
function try_migrate!(current_cell, dir, grid_size)
    if current_cell.is_alive && current_cell.nbmig < max_mig && !current_cell.has_migrated_this_step
        new_coords = current_cell.coordinates .+ dir
        if checkbounds(Bool, zeros(Int64, grid_size...), new_coords...) && !haskey(current_cells, new_coords)
            current_cell.nbmig += 1
            current_cell.has_migrate_this_step = true
            current_cell.coordinates = new_coords
            return true
        end
    end
    return false
end

"""Attempts to make a cell migrate in all possible directions for its type."""
function attempt_migration!(current_cells, cell, directions, max_cell_migration, grid_size)
    if cell.is_alive && !cell.has_migrated_this_step && haskey(directions, cell.cell_type)
        for dir in directions[cell.cell_type]
            if try_migrate!(current_cell, dir, grid_size) && cell.maxmig < max_migration
                cell.has_migrated_this_step = true
                return true
            end
        end
    end
    return cell.has_migrated_this_step
end

"""Triggers apoptosis (cell death) for a given cell based on a condition."""
function apoptosis!(next_cells, cell::ShapeGrowthModels.Cell, max_age::Int64)
    if cell.is_alive && cell.timer >= max_age
        delete!(next_cells, cell.coordinates)
        # Vous pourriez ajouter d'autres actions ici, comme marquer la cellule comme "morte" d'une certaine manière.
        println("Cell at $(cell.coordinates) underwent apoptosis at age $(cell.timer).")
        return true
    end
    return false
end