module SimulationModule



include("initialisation.jl")

function __init__()
    println("SimulationModule chargé.")
end

"""
    run_simulation_with_sequence(cell_type_sequence::Vector{Int64})

Crée les cellules initiales et exécute la simulation avec la séquence de types de cellules donnée.

# Arguments
- `cell_type_sequence::Vector{Int64}`: La séquence des types de cellules à utiliser dans la simulation.

# Retourne
- `Any`: Le résultat de la fonction `run_simulation`.  Cela pourrait être une animation, par exemple.
"""
function run_simulation_with_sequence(cell_type_sequence::Vector{Int64})
    xml_file = "cellTypesChange.xml" # Vous pouvez externaliser cela si nécessaire
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
    cell_types_to_load = unique(cell_type_sequence)  # Charger seulement les types utilisés
    cell_data = load_cell_data(xml_file, cell_types_to_load)

    # Créer un ensemble de cellules initiales
    initial_cells = CellSetByCoordinates(Dict{Tuple{Int64, Int64}, Int64}())
    initial_cells.cells[(25, 25)] = 1
    initial_cells.cells[(26, 25)] = 2
    initial_cells.cells[(25, 26)] = 3
    initial_cells.cells[(26, 26)] = 4 #ajouter une cellule

    # Lancer la simulation et retourner le résultat
    result = run_simulation(initial_cells, cell_data, num_steps, grid_size, max_cell_division, cell_type_sequence, xml_file=xml_file)
    rm(xml_file)
    return result
end

end # Fin du module SimulationModule

function main()
    # Exemple d'utilisation du module
    cell_type_sequence = [1, 2, 3, 1, 2, 3, 4]
    SimulationModule.run_simulation_with_sequence(cell_type_sequence)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end