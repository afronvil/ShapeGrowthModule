


function try_proliferate!(model::CellModel, cell::Cell,  dir_char::Char)
    max_cell_division = calculate_max_cell_divisions(model,cell)
    if !cell.is_alive || cell.nbdiv >= cell.max_cell_divisions || cell.has_proliferated_this_step
        return false
    end

    dir_vector = create_directions(dir_char, length(model.grid_size))
    new_coordinates = cell.coordinates .+ dir_vector
    is_in_bounds = all(1 <= new_coordinates[i] <= model.grid_size[i] for i in eachindex(new_coordinates))
    if is_in_bounds && !haskey(model.tissue_cells, new_coordinates)
        cell.last_division_type = cell.cell_type
        cell.initial_cell_type = cell.cell_type 
        cell.nbdiv += 1
        cell.has_proliferated_this_step = true    
        new_cell = create_new_cell(cell, new_coordinates)  
        new_cell.max_cell_divisions=calculate_max_cell_divisions(model, cell)
        model.tissue_cells[new_coordinates] = new_cell
    end
    return cell.has_proliferated_this_step
end

function try_differentiate!(model::CellModel, cell::Cell) 
    
    tissue_cells_to_differentiate = [cell for cell in values(model.tissue_cells) if cell.is_alive && !cell.has_proliferated_this_step]
    differentiated_and_proliferated = false
        original_cell = deepcopy(cell)
        start_index = isnothing(cell.current_type_index_in_sequence) ? 1 : cell.current_type_index_in_sequence
        for i in cell.current_type_index_in_sequence:length(model.cell_type_sequence)
            #= next_type = model.cell_type_sequence[i]
            cell.current_type_index_in_sequence = i =#
            if _attempt_differentiation_and_proliferation!(
                model,
                cell,
                i
                )
                #println("cell.nbdiv if : ", cell.nbdiv)
                differentiated_and_proliferated = true
                #cell.current_type_index_in_sequence = i
                return true
                break
            else 
                _restore_cell_state!(cell, original_cell) 
                differentiated_and_proliferated = false
                cell.cell_type=cell.last_division_type
                #_restore_cell_state!(model.tissue_cells, cell, original_cell_type, original_nbdiv)  =#
            end
        end
    #end

    return differentiated_and_proliferated
end

function _attempt_differentiation_and_proliferation!(
    model::CellModel,
    cell::Cell,
    i::Int64
    )::Bool 
    next_type = model.cell_type_sequence[i]
    cell.current_type_index_in_sequence = i
    original_cell = deepcopy(cell)
    has = false
    for dir in string(next_type)
        if dir == 'A' && cell.nbdiv < cell.max_cell_divisions
            delete!(model.tissue_cells, cell.coordinates) 
            cell.has_proliferated_this_step = true
            break
        else           
            cell.cell_type = next_type
            if try_proliferate!(model, cell, dir)
                cell.has_proliferated_this_step = true
                break
            else
                if i<length(model.cell_type_sequence)
                    next_type = model.cell_type_sequence[i+1]
                    differentiation!(model, cell, next_type)
                end
            end
        end
    end
    _restore_cell_state!(cell, original_cell)
    
    return cell.has_proliferated_this_step
end

function differentiation!(model::CellModel, cell::Cell, new_type::Symbol) 
    if cell.is_alive
        cell.cell_type = new_type
        cell.nbdiv = 0
    end
end

function apoptosis!(tissue_cells::Dict{Vector{Int64}, Cell}, cell::Cell)
    if cell.is_alive && haskey(tissue_cells, cell.coordinates)
        delete!(tissue_cells, cell.coordinates)
        return true
    end
    return false
end

function _restore_cell_state!(cell::Cell, original_cell::Cell) 
    cell=original_cell
    cell.nbdiv = original_cell.nbdiv 
    return cell
    
end

