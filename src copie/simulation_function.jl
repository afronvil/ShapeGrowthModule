function get_generated_form(cell_type_sequence::Vector{Int64}; max_div_sequence::Union{Vector{Int64}, Nothing} = nothing)
    xml_file = "cellTypes.xml"
    num_steps = 25
    grid_size = (30, 30)
    cases = Dict(
        1 => [(0, -1)],
        2 => [(-1, 0)],
        3 => [(0, 1)],
        4 => [(1, 0)],
    )

    initial_cells = CellSetByCoordinates(Dict(
        (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))) =>
            Cell(
                (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))),
                0,
                cell_type_sequence[1],
                cell_type_sequence[1],
                cell_type_sequence[1],
                0,
                0,
                true,
                false,
                1
            )
        ))

    # Fonction pour calculer le nombre maximal de divisions en fonction des coordonnées et du type de la cellule
    function calculate_max_divisions(cell_x, cell_y, cell_type)
        # Ceci est un exemple de fonction. Vous devez la remplacer par votre propre logique.
        # Exemple :
        # - Les cellules de type 1 se divisent plus près du centre.
        # - Les cellules de type 2 se divisent plus près des bords.
        distance_au_centre = sqrt((cell_x - grid_size[1] / 2)^2 + (cell_y - grid_size[2] / 2)^2)
        if cell_type == 1
            return Int(floor(10 - distance_au_centre / 3))  # Plus près du centre, plus de divisions
        elseif cell_type == 2
            return Int(floor(5 + distance_au_centre / 3))    # Plus près des bords, plus de divisions
        else
            return 7 # Valeur par défaut
        end
    end

    # Si max_div_sequence n'est pas fourni, le calculer en fonction des coordonnées et du type
    if max_div_sequence === nothing
        # Créer un vecteur de la même longueur que cell_type_sequence.
        max_div_sequence = Vector{Int64}(undef, length(cell_type_sequence))

        # Pour cet exemple, nous allons utiliser les types de cellules de cell_type_sequence
        # et leurs positions initiales pour calculer le nombre max de divisions.
        # Notez que cela suppose que vous voulez que le nombre maximal de divisions
        # soit basé sur les *types* de cellules initiaux, et non sur les types de cellules
        # qui peuvent changer au cours de la simulation.
        for (i, cell_type) in enumerate(cell_type_sequence)
            # Pour obtenir les coordonnées initiales, nous pourrions avoir besoin de plus d'informations.
            # Puisque nous n'avons qu'une seule cellule initiale ici, nous allons utiliser ses coordonnées.
            initial_cell_x = Int64(floor(grid_size[1] / 2))
            initial_cell_y = Int64(floor(grid_size[2] / 2))
            max_div_sequence[i] = calculate_max_divisions(initial_cell_x, initial_cell_y, cell_type)
        end
    end

    # Ajout d'une assertion pour vérifier les longueurs avant d'appeler run_simulation
    @assert length(cell_type_sequence) == length(max_div_sequence) "Erreur : cell_type_sequence et max_div_sequence doivent avoir la même longueur. Longueur de cell_type_sequence : $(length(cell_type_sequence)), Longueur de max_div_sequence : $(length(max_div_sequence))"

    run_simulation(initial_cells, num_steps, grid_size, cell_type_sequence; xml_file = xml_file, max_div_sequence = max_div_sequence)

    return "Simulation terminée"
end

# Exemples d'appels de la fonction :
cell_types_sequence1 = [1, 2, 3]
result1 = get_generated_form(cell_types_sequence1) # Pas de max_div_sequence fourni, calculé en interne.

cell_types_sequence2 = [1, 2, 3]
max_div_sequence2 = [2, 1, 4] # Changement ici pour tester l'erreur
result2 = get_generated_form(cell_types_sequence2, max_div_sequence = max_div_sequence2) # max_div_sequence fourni par l'utilisateur

println(result1)
println(result2)
