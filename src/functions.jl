
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

"""Tente de différencier une cellule et de la faire proliférer."""
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
function simulate_step!(current_cells, proliferation_directions, cell_type_sequence, max_cell_division, grid_size)
    reset_proliferation_status!(current_cells)
    next_cells = deepcopy(current_cells.cells)

    for cell_type in cell_type_sequence
        #@info ""
        #@info "Traitement du type de cellule : $cell_type "
        #@info ""
        cells_of_type = [cell for cell in values(current_cells.cells) if cell.is_alive && cell.cell_type == cell_type]

        #@info "***************************** 1. Prolifération pour le type actuel *********** "
        for cell in cells_of_type
            index =cell.current_type_index_in_sequence
            #@info "index : $index"
            attempt_proliferation!(next_cells, current_cells, cell, proliferation_directions, max_cell_division, grid_size)
            #@info "index : $index"
        end

        #@info "**************************** 2. Différenciation pour le type actuel  *****"
        for cell in cells_of_type
            
            if cell.is_alive && !cell.has_proliferated_this_step #&& cell.nbdiv < max_cell_division 
                
                #@info "Cellule $(cell.coordinates) (type $cell_type) tente de se différencier."
                try_differentiate!(next_cells, current_cells, cell_type_sequence, proliferation_directions, max_cell_division, grid_size, cell_type)
            end
            
        end
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

function create_directions_dict(cell_directions::Dict{Int64, Vector{Int64}}, cases::Dict{Int64, Vector{Tuple{Int64, Int64}}})
    result_dict = Dict{Int64, Vector{Tuple{Int64, Int64}}}()
    for (cell_type, directions) in cell_directions
        result_dict[cell_type] = directions_to_tuples(directions, cases)
    end
    return result_dict
end




"""Lance la simulation cellulaire."""

function run_simulation(initial_cells::CellSetByCoordinates, num_steps::Int64, grid_size::Tuple{Int64, Int64}, max_cell_division::Int64, cell_type_sequence::Vector{Int64}; xml_file::String = "cellTypesChange.xml")
    history = [deepcopy(initial_cells)]
    current_cells = deepcopy(initial_cells)
    cell_data=load_cell_data(xml_file, cell_types_to_load)
    cell_directions = create_directions(cell_data)
    proliferation_directions = create_directions_dict(cell_directions, cases)
    cell_data = load_cell_data(xml_file, cell_types_to_load)
    anim = @animate for step in 0:num_steps
        visualize_cells(current_cells, step, grid_size, cell_data)
        if step < num_steps
            current_cells = simulate_step!(current_cells, proliferation_directions, cell_type_sequence, max_cell_division, grid_size)
            push!(history, deepcopy(current_cells))
        end
    end
    gif(anim, "cellular_dynamics.gif", fps=1)
    println("Simulation terminée (mise à jour après tous les types) et la visualisation a été sauvegardée.")
    # anim2 = @animate for i in 1:length(history)
    #     visualize_cells(history[i], i - 1, grid_size, cell_type_colors)
    # end
    # gif(anim2, "cellular_dynamics_history.gif", fps=1)
end

# Module definition as a function
function run_simulation_with_sequence(cell_type_sequence::Vector{Int64})
    xml_file = "cellTypesChange.xml"
    grid_size = (50, 50)
    num_steps = 10
    max_cell_division = 2

    # Créer un fichier XML factice pour les tests
    test_xml = """
    <gene>
        <genome ID="0" nbType="134">
            <cellType type="1" color0="1.0" color1="0.0" color2="0.0" nbDir="1" dir0="0"/>
            <cellType type="2" color0="0.0" color1="1.0" color2="0.0" nbDir="1" dir0="6"/>
            <cellType type="3" color0="0.0" color1="0.0" color2="1.0" nbDir="1" dir0="4"/>
            <cellType type="4" color0="1.0" color1="1.0" color2="0.0" nbDir="1" dir0="0"/>
        </genome>
    </gene>
    """
    write(xml_file, test_xml)

    # Charger les données des cellules
    cell_types_to_load = unique(cell_type_sequence)
    cell_data = load_cell_data(xml_file, cell_types_to_load)

    # Créer un ensemble de cellules initiales
    initial_cells = CellSetByCoordinates(Dict{Tuple{Int64, Int64}, Int64}())
    initial_cells.cells[(25, 25)] = 1
    initial_cells.cells[(26, 25)] = 2
    initial_cells.cells[(25, 26)] = 3
    initial_cells.cells[(26, 26)] = 4

    # Lancer la simulation et retourner le résultat
    result = run_simulation(initial_cells, cell_data, num_steps, grid_size, max_cell_division, cell_type_sequence, xml_file=xml_file)
    rm(xml_file)
    return result
end
