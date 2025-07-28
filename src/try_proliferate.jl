function try_proliferate!(model::CellModel{Dim}, cells::Dict{NTuple{Dim, Int64}, Cell{Dim}} ,
    cell_type::Int64)::next_cells::Dict{NTuple{Dim, Int64}, Cell{Dim}}
    directions = get(model.processed_proliferation_directions, parent_cell.cell_type, [ntuple(_ -> 0, Dim)])
            
    for dir in directions
        for cell in cells
            if cell.is_alive
                new_coords = cell.coordinates .+ dir
                if is_in_bounds(new_coords) && !haskey(next_cells, new_coords)
                    if parent_cell.is_alive && parent_cell.nbdiv < max_div && !parent_cell.has_proliferated_this_step
                        update_after_proliferation(parent_cell)
                        create_new_cell(
                            new_coords,
                            create_new_cell_from_parent(cell, new_coords),   
                            cell.cell_type,
                            cell.initial_cell_type,
                            cell.last_division_type,
                            cell.nbdiv,
                            cell.max_divisions,
                            true,
                            false,
                            cell.current_type_index_in_sequence
                        )
                        return true
                    end
                end
            end
        end
    end
    return next_cells
end

function try_proliferate!(
    model::CellModel{Dim}, # Le modèle contient la grille, les règles, etc.
    current_cells::Dict{NTuple{Dim, Int64}, Cell{Dim}} # Les cellules actuelles pour cette étape
)::Dict{NTuple{Dim, Int64}, Cell{Dim}} where Dim # Spécifiez `Dim` ici
    
    next_cells = deepcopy(current_cells) # Crée une copie pour modifier en toute sécurité
    already_proliferated_coords = Set{NTuple{Dim, Int64}}()
    all_possible_directions = Set{NTuple{Dim, Int64}}()
    for (cell_type, dirs) in model.processed_proliferation_directions
        union!(all_possible_directions, Set(dirs))
    end
    sorted_directions = collect(all_possible_directions) # Convertit en vecteur pour un ordre d'itération défini

    # External loop: Browse every possible direction
    for dir in sorted_directions
        # Internal loop: Scroll through each existing cell at the start of the step
        for coords in keys(current_cells)
            parent_cell = current_cells[coords] 

            # Checks if the cell is eligible to proliferate and has not already done so this step
            if parent_cell.is_alive && !(coords in already_proliferated_coords)
                
                # Obtain specific directions for this type of cell
                type_specific_directions = get(model.processed_proliferation_directions, parent_cell.cell_type, [ntuple(_ -> 0, Dim)])
                
                # If the current loop direction is permitted for this cell type
                if dir in type_specific_directions
                    
                    new_coords = parent_cell.coordinates .+ dir # Calculer les nouvelles coordonnées

                    max_div = parent_cell.max_divisions # Utiliser la max_divisions de la cellule parente

                    # Check whether the parent cell can still be divided and whether the new position is valid and empty.
                    if parent_cell.nbdiv < max_div && 
                       is_in_bounds(new_coords, model.grid_size, Val(Dim)) && 
                       !haskey(next_cells, new_coords) # Vérifier `next_cells` pour l'occupation!
                        
                        # Successful proliferation!
                        update_after_proliferation!(parent_cell) # Mettre à jour l'état de la cellule parente
                        push!(already_proliferated_coords, coords) # Marquer cette cellule comme ayant proliféré
                        
                        # Determine the type of new cell based on the sequence
                        next_index_in_sequence = (parent_cell.current_type_index_in_sequence % length(model.cell_type_sequence)) + 1
                        new_cell_type = model.cell_type_sequence[next_index_in_sequence]

                        # Get max_divisions for the new cell type from model.cell_data
                        new_cell_max_div = get(model.cell_data[new_cell_type], "max_cell_division", 0)

                        # Create a new cell with the correct arguments
                        new_cell = create_new_cell(
                            new_coords, 
                            0, # timer for the new cell
                            new_cell_type, 
                            new_cell_type, # initial_cell_type for the new cell
                            parent_cell.cell_type, # last_division_type is the type of the parent
                            0, # nbdiv for the new cell
                            new_cell_max_div, # max_divisions for the new cell
                            true, # is_alive
                            false, # has_proliferated_this_step 
                            next_index_in_sequence #current_type_index_in_sequence for the new cell
                        )
                        
                        next_cells[new_coords] = new_cell # Add the new cell to the dictionary

                        # The break logic for this parent cell in the direction iteration
                        # is managed by `already_proliferated_coords`.
                    end
                end 
            end 
        end 
    end 

    return next_cells # Resend updated dictionary
end













function is_in_bounds(cell)
    is_in_bounds = true
    for i in 1:Dim
        if !(1 <= new_coords[i] <= model.grid_size[i])
            is_in_bounds = false
            break
        end
    end
    return is_in_bounds
end

function create_new_cell(parent_cell, coords)
    new_cell = Cell{Dim}(new_coords, 0, parent_cell.cell_type, parent_cell.cell_type, parent_cell.last_division_type, parent_cell.nbdiv, parent_cell.nbdiv, true, false, next_index_in_sequence)  
function create_new_cell_from_parent(parent_cell, coords)
    new_cell = Cell{Dim}(coords, 0, parent_cell.cell_type, parent_cell.cell_type, parent_cell.last_division_type, parent_cell.nbdiv, parent_cell.nbdiv, true, false, next_index_in_sequence)  
end
    parent_cell.nbdiv += 1
    parent_cell.has_proliferated_this_step = true
end

 for cell_type in cell_type_sequence
        cells_of_type_dict = Dict{NTuple{Dim, Int64}, Cell{Dim}}(
            coord => cell
            for (coord, cell) in current_cells
            if cell.is_alive && cell.cell_type == cell_type
        )


function create_new_cell(
    coordinates::NTuple{Dim, Int64},
    timer::Int64,
    cell_type::Int64,
    initial_cell_type::Int64,
    last_division_type::Int64,
    nbdiv::Int64,
    max_divisions::Int64,
    is_alive::Bool,
    has_proliferated_this_step::Bool,
    current_type_index_in_sequence::Int64
)::Cell{Dim} where Dim   

    return Cell{Dim}(
        coordinates=coordinates,
        timer=timer,
        cell_type=cell_type,
        initial_cell_type=initial_cell_type,
        last_division_type=last_division_type,
        nbdiv=nbdiv,
        max_divisions=max_divisions,
        is_alive=is_alive,
        has_proliferated_this_step=has_proliferated_this_step,
        current_type_index_in_sequence=current_type_index_in_sequence
    )
end

# Updates the parent cell after a division.

function update_after_proliferation!(parent_cell::Cell{Dim}) where Dim
    parent_cell.nbdiv += 1
    parent_cell.has_proliferated_this_step = true
    # Vous pourriez aussi vouloir changer le type de la cellule mère si la séquence le dicte
    # parent_cell.cell_type = model.cell_type_sequence[parent_cell.current_type_index_in_sequence]
    # Mais cela dépend de votre logique métier.
    return nothing # La fonction modifie l'objet en place, pas besoin de retourner
end