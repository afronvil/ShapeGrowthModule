using ColorSchemes
using Plots
# --- Fonctions de dynamique cellulaire ---

"""Tente de faire proliférer une cellule dans une direction donnée."""
function try_proliferate!(next_cells, parent_cell, dir, max_div, grid_size)
    #@debug "try_proliferate! : $(parent_cell.coordinates) dir : $dir cell_type : $(parent_cell.cell_type) last_division_type : $(parent_cell.last_division_type) nbdiv : $(parent_cell.nbdiv)"
    if parent_cell.is_alive && parent_cell.nbdiv < max_div && !parent_cell.has_proliferated_this_step
        new_coords = parent_cell.coordinates .+ dir
        if checkbounds(Bool, zeros(Int64, grid_size...), new_coords...) && !haskey(next_cells, new_coords )
            parent_cell.last_division_type = parent_cell.cell_type
            parent_cell.nbdiv += 1
            next_index_in_sequence = parent_cell.current_type_index_in_sequence
            new_cell = Cell(new_coords, 0, parent_cell.cell_type,parent_cell.cell_type, parent_cell.last_division_type, parent_cell.nbdiv,parent_cell.nbdiv, true, false, next_index_in_sequence )
            parent_cell.has_proliferated_this_step = true
            new_cell.has_proliferated_this_step = true
            next_cells[parent_cell.coordinates] = parent_cell
            next_cells[new_coords] = new_cell
            #@info "Cellule $(parent_cell.coordinates) (index $(next_index_in_sequence) type $(parent_cell.cell_type), div: $(parent_cell.nbdiv)) se divise en $(new_coords) (type $(parent_cell.cell_type), div: $(parent_cell.nbdiv))"
            return true
            
        end
    end
    #@debug "parent_cell.has_proliferated_this_step : $(parent_cell.has_proliferated_this_step)"
    #@debug "try_proliferate! fin : $(parent_cell.coordinates) cell_type : $(parent_cell.cell_type) last_division_type : $(parent_cell.last_division_type) nbdiv : $(parent_cell.nbdiv)"
    return false
end

"""Tente de faire proliférer une cellule dans toutes les directions possibles pour son type."""
function attempt_proliferation!(next_cells, current_cells, cell, directions, max_div, grid_size)
    if cell.is_alive && !cell.has_proliferated_this_step && haskey(directions, cell.cell_type) 
        for dir in directions[cell.cell_type]
            if try_proliferate!(next_cells, deepcopy(cell), dir, max_div, grid_size) && cell.nbdiv < max_div
                cell.has_proliferated_this_step = true
                return true
            end
        end
    end
    return cell.has_proliferated_this_step
end

"""Effectue la différenciation d'une cellule vers un nouveau type."""
function differentiation!(next_cells, cell::Cell, new_type::Int64)
    if cell.is_alive
        cell.cell_type = new_type
        cell.nbdiv = 0
        next_cells[cell.coordinates] = cell
    end
end

"""Tente de différencier les cellules puis de les faire proliférer."""
function try_differentiate!(next_cells, current_cells, cell_type_sequence::Vector{Int64}, proliferation_directions::Dict{Int64, Vector{Tuple{Int64, Int64}}}, max_cell_division::Int64, grid_size::Tuple{Int64, Int64}, cell_type_to_process::Int64)
    cells_to_differentiate = [cell for cell in values(current_cells.cells) if cell.is_alive && cell.cell_type == cell_type_to_process && !cell.has_proliferated_this_step]

    #@info "--- try_differentiate! pour le type $cell_type_to_process ($(length(cells_to_differentiate)) cellules) ---"

    processed_cells = Set{Tuple{Int64, Int64}}() # Suivre les cellules traitées avec succès
    
    for cell in cells_to_differentiate
        
        #println("cell in cells_to_differentiate")
        
        if cell.coordinates in processed_cells
            continue # Si la cellule a déjà différencié et proliféré, passer à la suivante
        end

        original_state = deepcopy(cell)
        differentiation_attempted = false
        proliferation_succeeded_once = false

        #@info "  Cellule $(cell.coordinates) (type $(cell.cell_type), div: $(cell.nbdiv), index: $(cell.current_type_index_in_sequence)) : Début des tentatives de différenciation."

        start_index = isnothing(cell.current_type_index_in_sequence) ? 1 : cell.current_type_index_in_sequence

        for i in  start_index+1:length(cell_type_sequence)
            #next_index_in_sequence = mod1(start_index + i, length(cell_type_sequence))
            
            next_index_in_sequence = i
            
            next_possible_type = cell_type_sequence[i]
            #println("next_index_in_sequence = ",next_index_in_sequence, "next_possible_type = ",cell_type_sequence[i])
            #@info "    Tentative $i : vers l'index $next_index_in_sequence (type $next_possible_type)."
            differentiation!(next_cells, cell, next_possible_type)
            #@info "      Cellule $(cell.coordinates) index $next_index_in_sequence différenciée en type $next_possible_type (nbdiv réinitialisé à 0)."
            differentiation_attempted = true

            if haskey(proliferation_directions, next_possible_type)
                temp_cell = deepcopy(next_cells[cell.coordinates])
                proliferated = false
                for dir in proliferation_directions[next_possible_type]

                    temp_cell.current_type_index_in_sequence = next_index_in_sequence
                    proliferated = try_proliferate!(next_cells, temp_cell, dir, max_cell_division,  grid_size)
                    #@info "        Tentative de prolifération en direction $dir : succès = $proliferated : index $temp_cell.next_index_in_sequence."
                    if proliferated
                        proliferation_succeeded_once = true
                        #@info "      Cellule $(cell.coordinates) a proliféré après différenciation en type $next_possible_type index $next_index_in_sequence ."
                        # Mettre à jour l'état de la cellule mère dans next_cells
                        temp_cell.current_type_index_in_sequence=next_index_in_sequence
                        next_cells[cell.coordinates] = temp_cell
        
                        push!(processed_cells, cell.coordinates) # Marquer comme traitée
                        # Mettre à jour l'objet 'cell' local pour refléter le nouvel état et son index
                        cell.cell_type = temp_cell.cell_type
                        cell.nbdiv = temp_cell.nbdiv
                        cell.has_proliferated_this_step = true
                        cell.current_type_index_in_sequence = temp_cell.current_type_index_in_sequence # Mettre à jour l'index
                        break
                    end
                end
                if proliferation_succeeded_once

                    break # Prolifération réussie, passer à la prochaine cellule
                else
                    # La prolifération a échoué pour ce type, on restaure l'état original pour la prochaine tentative
                    next_cells[cell.coordinates] = original_state
                    cell.cell_type = original_state.cell_type
                    cell.nbdiv = original_state.nbdiv
                    # On ne met PAS à jour l'index ici car la différenciation n'a pas été "validée" par une prolifération
                    #@info "      La prolifération a échoué pour le type $next_possible_type. Restauration temporaire de l'état."
                end
            else
                #@info " Pas de directions de prolifération pour le type $next_possible_type."
                next_cells[cell.coordinates] = original_state
                cell.cell_type = original_state.cell_type
                cell.nbdiv = original_state.nbdiv
                # On ne met PAS à jour l'index ici car la différenciation n'a pas été "validée" par une prolifération
                #@info "      Restauration temporaire de l'état car pas de directions de prolifération."
            end
        end

        if !proliferation_succeeded_once && differentiation_attempted && haskey(next_cells, cell.coordinates)
            #@warn "  Cellule $(cell.coordinates) n'a pas réussi à proliférer après toutes les tentatives de différenciation. Passage à l'état is_alive = false et retour à l'état original."
            next_cells[cell.coordinates] = original_state
            next_cells[cell.coordinates].is_alive = false
        elseif proliferation_succeeded_once

            #@info "  Cellule $(cell.coordinates) a réussi à différencier et à proliférer (nouveau type : $(next_cells[cell.coordinates].cell_type), nbdiv : $(next_cells[cell.coordinates].nbdiv), nouvel index :  $(next_cells[cell.coordinates].current_type_index_in_sequence))."
            break
        elseif !differentiation_attempted
            #@debug "  Cellule $(cell.coordinates) n'a pas tenté de différenciation."
        end
    end
    #@info "--- Fin de try_differentiate! pour le type $cell_type_to_process ---"
end


"""Met à jour le timer des cellules vivantes."""
function update_cell_state!(next_cells)
    for cell in values(next_cells)
        cell.is_alive && (cell.timer += 1)
    end
end

"""Réinitialise le statut de prolifération pour toutes les cellules au début d'une étape."""
function reset_proliferation_status!(current_cells)
    for cell in values(current_cells.cells)
        cell.has_proliferated_this_step = false
    end
end


"""Simule une étape de l'évolution cellulaire."""
function simulate_step!(current_cells::CellSetByCoordinates, 
    proliferation_directions::Dict{Int64, Vector{Tuple{Int64, Int64}}}, 
    cell_type_sequence::Vector{Int64}, 
    max_cell_divisions_dict::Dict{Int64, Int64}, 
    grid_size::Tuple{Int64, Int64})

    reset_proliferation_status!(current_cells)
    next_cells = deepcopy(current_cells.cells)
    
    for cell_type in cell_type_sequence
        cells_of_type = [cell for cell in values(current_cells.cells) if cell.is_alive && cell.cell_type == cell_type]

        for cell in cells_of_type
            max_cell_division = max_cell_divisions_dict[cell.cell_type] # Get max_cell_division here
            attempt_proliferation!(next_cells, current_cells, cell, proliferation_directions, max_cell_division, grid_size)
        end

        for cell in cells_of_type
            max_cell_division = max_cell_divisions_dict[cell.cell_type] #and also here
            if cell.is_alive && !cell.has_proliferated_this_step
            try_differentiate!(next_cells, current_cells, cell_type_sequence, proliferation_directions, max_cell_division, grid_size, cell_type)
        end
        end
    end

    update_cell_state!(next_cells)


    

    return CellSetByCoordinates(next_cells)
end


function simulate_step!(current_cells::CellSetByCoordinates, 
    proliferation_directions::Dict{Int64, Vector{Tuple{Int64, Int64}}}, 
    cell_type_sequence::Vector{Int64}, 
    max_div_sequence::Vector{Int64}, 
    grid_size::Tuple{Int64, Int64})

    reset_proliferation_status!(current_cells)
    next_cells = deepcopy(current_cells.cells)
    i=1
    for cell_type in cell_type_sequence
        cells_of_type = [cell for cell in values(current_cells.cells) if cell.is_alive && cell.cell_type == cell_type]

        for cell in cells_of_type
            max_cell_division = max_div_sequence[i]
            attempt_proliferation!(next_cells, current_cells, cell, proliferation_directions, max_cell_division, grid_size)
        end

        for cell in cells_of_type
            max_cell_division = max_div_sequence[i]
            if cell.is_alive && !cell.has_proliferated_this_step
                try_differentiate!(next_cells, current_cells, cell_type_sequence, proliferation_directions, max_cell_division, grid_size, cell_type)
            end
        end
    end

    update_cell_state!(next_cells)

    return CellSetByCoordinates(next_cells)
end

function simulate_step!(current_cells::CellSetByCoordinates,        #quuand on veut que ce soit une fonction 
    proliferation_directions::Dict{Int64, Vector{Tuple{Int64, Int64}}}, 
    cell_type_sequence::Vector{Int64}, 
    max_cell_divisions_dict::Dict{Int64, Int64}, 
    grid_size::Tuple{Int64, Int64})
    max_cell_divisions_dict[cell_type_sequence[1]]=6

    reset_proliferation_status!(current_cells)
    next_cells = deepcopy(current_cells.cells)
    
    i=1
    for cell_type in cell_type_sequence 
        max_cell_division= max_cell_divisions_dict[cell_type_sequence[1]]

        cells_of_type = [cell for cell in values(current_cells.cells) if cell.is_alive && cell.cell_type == cell_type]

        for cell in cells_of_type
            attempt_proliferation!(next_cells, current_cells, cell, proliferation_directions, max_cell_division, grid_size)
         
        end
        for cell in cells_of_type
            
            if cell.is_alive && !cell.has_proliferated_this_step
                if !(haskey(max_cell_divisions_dict, cell_type_sequence[i]))
                    max_cell_division = calculate_max_divisions(cell)
                    max_cell_divisions_dict[cell_type_sequence[i]]= max_cell_division
                else
                    max_cell_division = max_cell_divisions_dict[cell_type_sequence[i]]
                end
                try_differentiate!(next_cells, current_cells, cell_type_sequence, proliferation_directions, max_cell_division, grid_size, cell_type)
            end
        end
        i+=1
    end
    update_cell_state!(next_cells)
    return CellSetByCoordinates(next_cells)
end


function directions_to_tuples(directions::Vector{Int64}, cases::Dict{Int64, Vector{Tuple{Int64, Int64}}})
    new_directions = Vector{Tuple{Int64, Int64}}()
    for direction in directions
        if haskey(cases, direction)
            append!(new_directions, cases[direction])
        else
            push!(new_directions, (0, 0)) # valeur par défaut
        end
    end
    return new_directions
end

function create_max_cell_divisions_dict(cell_data::Dict{Int64, Dict{String, Any}})
    max_cell_divisions = Dict{Int64, Int64}() # Change Vector{Int64} to Int64
    for (cell_type, data) in cell_data
        max_cell_divisions[cell_type] = data["max_cell_division"] # Accède à la valeur
        
    end
    return max_cell_divisions
end

function create_max_cell_divisions_dict(cell_types_sequence::Vector{Int64}, max_div_sequence::Vector{Int64})
    # Vérifie si les séquences ont la même longueur. Si ce n'est pas le cas, cela peut entraîner des erreurs.
    if length(cell_types_sequence) != length(max_div_sequence)
        throw(ArgumentError("Les séquences doivent avoir la même longueur."))
    end

    # Initialise un dictionnaire vide pour stocker le résultat.
    max_cell_divisions = Dict{Int64, Int64}()

    # Itère sur les éléments des deux séquences en utilisant leurs indices.
    for i in 1:length(cell_types_sequence)
        # Associe le type de cellule (de cell_types_sequence) au nombre maximal de divisions (de max_div_sequence).
        cell_type = cell_types_sequence[i]
        max_div = max_div_sequence[i]
        max_cell_divisions[cell_type] = max_div
    end

    # Retourne le dictionnaire résultant.
    return max_cell_divisions
end



"""
# Retourne `Dict{Int64, Vector{Int64}}`: Un dictionnaire où les clés sont les types de cellules et 
# les valeurs sont les vecteurs de directions de prolifération.
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

"""
Récupère les coordonnées de toutes les cellules présentes dans un ensemble de cellules.
"""

function get_cell_coordinates(cell_set::CellSetByCoordinates)
    return collect(keys(cell_set.cells))
end
"""
Calcule le nombre maximal de divisions qu'une cellule peut effectuer,
en fonction de ses coordonnées et de son type.
"""

function calculate_max_divisions(cell::Cell)
    
    return cell_type_to_max_divisions_function[cell.cell_type](cell)
end

"""
Lance la simulation cellulaire.
"""

function run_simulation(initial_cells::CellSetByCoordinates, num_steps::Int64, grid_size::Tuple{Int64, Int64},  cell_type_sequence::Vector{Int64}; xml_file::String = "cellTypesChange.xml", max_div_sequence::Vector{Int64}, toto::Bool=false)
    history = [deepcopy(initial_cells)]
    current_cells = CellSetByCoordinates(Dict{Tuple{Int64, Int64}, Cell}())
    cell_data=load_cell_data(xml_file, cell_types_sequence)
    if toto==true
        println("toto")
        max_cell_divisions_dict = create_max_cell_divisions_dict()
    elseif isempty(max_div_sequence)
        max_cell_divisions_dict = create_max_cell_divisions_dict(cell_data)
    else
        max_cell_divisions_dict = create_max_cell_divisions_dict(cell_types_sequence, max_div_sequence)
    end
    
    cell_directions = create_directions(cell_data)
    proliferation_directions = create_directions_dict(cell_directions, cases)
    step=1
    new_cells=deepcopy(initial_cells)
    
    #anim = @animate 
    while  !(get_cell_coordinates(current_cells) == get_cell_coordinates(new_cells)) 
    ##anim = @animate for step in 1:num_steps
        current_cells=deepcopy(new_cells)
        #visualize_cells(current_cells, step, grid_size, cell_data)
        #println(get_cell_coordinates(current_cells))
        new_cells = simulate_step!(current_cells, proliferation_directions, cell_type_sequence, max_cell_divisions_dict, grid_size)
        println("max_cell_divisions_dict = ", max_cell_divisions_dict)
        #println(get_cell_coordinates(new_cells))
        push!(history, deepcopy(current_cells))
        step+=1
    end
    #gif(anim, "cellular_dynamics.gif", fps=1)
    #println("Simulation terminée (mise à jour après tous les types) et la visualisation a été sauvegardée.")
    visualize_cells(history[step], step, grid_size, cell_data)
end


function cellular_dynamics(current_cells::CellSetByCoordinates ,num_steps::Int64, grid_size::Tuple{Int64, Int64}, xml_file::String = "cellTypesChange.xml")
    # Définir les directions de prolifération
    cases = Dict(
        1 => [(0, -1)], #Ouest
        2 => [(-1, 0)], #Nord
        3 => [(0, 1)],  #Est
        4 => [(1, 0)],  #Sud
        5 => [(1, -1)], #Sud-Ouest
        6 => [(-1, -1)],#Nord-Ouest
        7 => [(1, 1)], #Sud-Est
        8 => [(-1, 1)]#Nord-Est
    )
    new_cells = simulate_step!(current_cells, proliferation_directions, cell_type_sequence, max_cell_divisions, grid_size)


end    

