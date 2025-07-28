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
    #filter!(d -> any(d .!= 0), all_possible_directions) # Exclut la direction (0,0,0) si elle existe
    sorted_directions = collect(all_possible_directions) # Convertit en vecteur pour un ordre d'itération défini

    # Boucle externe: Parcourir chaque direction possible
    for dir in sorted_directions
        # Boucle interne: Parcourir chaque cellule existante au début de l'étape
        for coords in keys(current_cells)
            parent_cell = current_cells[coords] 

            # Vérifie si la cellule est éligible pour proliférer et ne l'a pas déjà fait cette étape
            if parent_cell.is_alive && !(coords in already_proliferated_coords)
                
                # Obtenir les directions spécifiques à ce type de cellule
                type_specific_directions = get(model.processed_proliferation_directions, parent_cell.cell_type, [ntuple(_ -> 0, Dim)])
                
                # Si la direction actuelle du loop est permise pour ce type de cellule
                if dir in type_specific_directions
                    
                    new_coords = parent_cell.coordinates .+ dir # Calculer les nouvelles coordonnées

                    max_div = parent_cell.max_divisions # Utiliser la max_divisions de la cellule parente

                    # Vérifier si la cellule parente peut encore se diviser et si la nouvelle position est valide et vide
                    if parent_cell.nbdiv < max_div && 
                       is_in_bounds(new_coords, model.grid_size, Val(Dim)) && 
                       !haskey(next_cells, new_coords) # Vérifier `next_cells` pour l'occupation!
                        
                        # Prolifération réussie!
                        update_after_proliferation!(parent_cell) # Mettre à jour l'état de la cellule parente
                        push!(already_proliferated_coords, coords) # Marquer cette cellule comme ayant proliféré
                        
                        # Déterminer le type de la nouvelle cellule en fonction de la séquence
                        next_index_in_sequence = (parent_cell.current_type_index_in_sequence % length(model.cell_type_sequence)) + 1
                        new_cell_type = model.cell_type_sequence[next_index_in_sequence]

                        # Obtenir max_divisions pour le nouveau type de cellule depuis model.cell_data
                        new_cell_max_div = get(model.cell_data[new_cell_type], "max_cell_division", 0)

                        # Créer la nouvelle cellule avec les arguments corrects
                        new_cell = create_new_cell(
                            new_coords, 
                            0, # timer pour la nouvelle cellule
                            new_cell_type, 
                            new_cell_type, # initial_cell_type pour la nouvelle cellule
                            parent_cell.cell_type, # last_division_type est le type du parent
                            0, # nbdiv pour la nouvelle cellule
                            new_cell_max_div, # max_divisions pour la nouvelle cellule
                            true, # is_alive
                            false, # has_proliferated_this_step (pour la *prochaine* étape)
                            next_index_in_sequence # current_type_index_in_sequence pour la nouvelle cellule
                        )
                        
                        next_cells[new_coords] = new_cell # Ajouter la nouvelle cellule au dictionnaire

                        # La logique du `break` pour cette cellule parente dans l'itération des directions
                        # est gérée par `already_proliferated_coords`.
                    end
                end 
            end 
        end 
    end 

    return next_cells # Renvoyer le dictionnaire mis à jour
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
        cells_of_type_dict = Dict{NTuple{Dim, Int64}, Shape_Growth_Populate.Cell{Dim}}(
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
    # Assurez-vous d'importer `Cell` depuis votre module si cette fonction est définie ailleurs.
    # Ex: Shape_Growth_Populate.Cell{Dim}
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


# --- 4. Fonction update_after_proliferation! ---
# Met à jour la cellule parente après une division.

function update_after_proliferation!(parent_cell::Cell{Dim}) where Dim
    parent_cell.nbdiv += 1
    parent_cell.has_proliferated_this_step = true
    # Vous pourriez aussi vouloir changer le type de la cellule mère si la séquence le dicte
    # parent_cell.cell_type = model.cell_type_sequence[parent_cell.current_type_index_in_sequence]
    # Mais cela dépend de votre logique métier.
    return nothing # La fonction modifie l'objet en place, pas besoin de retourner
end