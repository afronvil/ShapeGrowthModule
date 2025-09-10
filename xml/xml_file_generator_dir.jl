using Colors
using DataStructures # Pour utiliser Set

function generate_cell_type_xml(directions)
    
    # Créer une correspondance des directions numériques vers des lettres
    direction_mapping = Dict(
        0 => 'A',
        1 => 'Q',
        2 => 'W',
        3 => 'N',
        4 => 'E',
        5 => 'S'
    )
    
    # Construire le nouvel identifiant basé sur les directions converties en lettres
    new_type_id_parts = []
    for dir in directions
        # Utiliser get pour obtenir la lettre correspondante, sinon une chaîne vide si la clé n'existe pas
        letter = get(direction_mapping, dir, "")
        push!(new_type_id_parts, string(letter))
        if dir == 0 || dir == 1
            break
        end
    end
    new_type_id = join(new_type_id_parts, "_")

    color = RGB(rand(), rand(), rand())
    xml_line = "<cellType type=\"$(new_type_id)\" "
    xml_line *= "color0=\"$(red(color))\" color1=\"$(green(color))\" color2=\"$(blue(color))\" "
    xml_line *= "max_cell_division=\"6\" "
    for i in 0:length(directions)-1
        xml_line *= "dir$(i)=\"$(directions[i+1])\" "
    end
    xml_line *= "/>\n"
    return xml_line
end

function generate_unique_constrained_directions(possible_directions, num_elements, type_sequence)
    all_xml_lines = []
    seen_directions = Set{Vector{Int}}()
    indices_iterator = Iterators.product(fill(1:length(possible_directions), num_elements)...)
    
    for idx_tuple in indices_iterator
        directions = collect(possible_directions[i] for i in idx_tuple)
        constrained_directions = copy(directions)

        first_zero_one_index = findfirst(x -> x == 0 || x == 1, directions)
        if first_zero_one_index !== nothing
            for i in (first_zero_one_index + 1):num_elements
                constrained_directions[i] = 1
            end
        end

        non_zero_elements = filter(x -> x != 1, constrained_directions)
        if length(unique(non_zero_elements)) == length(non_zero_elements)
            if !(constrained_directions in seen_directions)
                push!(seen_directions, constrained_directions)
                xml_line = generate_cell_type_xml(constrained_directions)
                push!(all_xml_lines, xml_line)
            end
        end
    end
    return all_xml_lines
end

function write_xml_to_file(filename, xml_lines)
    open(filename, "w") do io
        write(io, "<gene>\n")
        write(io, "<genome>\n")
        for line in xml_lines
            write(io, line)
        end
        write(io, "</genome>\n")
        write(io, "</gene>\n")
    end
    println("Les combinaisons de directions uniques et contraintes ont été écrites dans le fichier : $(filename)")
end

# Définir les directions possibles et le nombre d'éléments
possible_directions = 0:5
num_elements = 6
type_sequence_to_iterate = 1:134 

# Générer les combinaisons de directions uniques et contraintes
all_unique_constrained_xml = generate_unique_constrained_directions(possible_directions, num_elements, type_sequence_to_iterate)

# Écrire les combinaisons dans un nouveau fichier XML
output_filename = "essai_dir0_is_0_1_or_2.xml"
write_xml_to_file(output_filename, all_unique_constrained_xml)

println("Nombre total de combinaisons uniques et contraintes générées : $(length(all_unique_constrained_xml))")