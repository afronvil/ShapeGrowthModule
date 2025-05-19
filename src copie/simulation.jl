

using Plots
using ColorTypes

include("struct_cell_env.jl")
include("initialization.jl")
include("functions.jl")

include("data_xml.jl")
include("visualization_xml.jl")

include("struct_cell_env.jl")
#max_div_sequence = 6

# # --- Lancement de la simulation ---

#run_simulation(initial_cells, num_steps, grid_size, cell_types_sequence; xml_file)
cell_type_sequence = [1, 2, 3, 1]
#max_div_sequence = [5, 10, 5, 8] 

function get_generated_form(cell_type_sequence::Vector{Int64}; max_div_sequence::Union{Vector{Int64}, Nothing} = nothing)
    xml_file = "cellTypes.xml"  # Vous devrez peut-être ajuster le nom du fichier XML
    num_steps = 25 # Nombre d'étapes de simulation
    grid_size = (30, 30) # Taille de la grille
    cases = Dict(
        1 => [(0, -1)], #Ouest
        2 => [(-1, 0)], #Nord
        3 => [(0, 1)],  #Est
        4 => [(1, 0)],  #Sud
        # 5 => [(1, -1)], #Sud-Ouest
        # 6 => [(-1, -1)],#Nord-Ouest
        # 7 => [(1, 1)], #Sud-Est
        # 8 => [(-1, 1)]#Nord-Est
    )

    initial_cells = CellSetByCoordinates(Dict(
        (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))) =>
            Cell(
                (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))),
                0,
                cell_type_sequence[1],
                cell_type_sequence[1],  # initial_cell_type
                cell_type_sequence[1],
                0,
                0, #initial_nbdiv
                true,
                false,
                1     # current_type_index_in_sequence
            )
        ))

    # Exécuter la simulation
    if max_div_sequence === nothing
        # Si max_div_sequence n'est pas fourni, créer un vecteur par défaut
        # Vous devrez peut-être ajuster cette logique par défaut en fonction de vos besoins.
        #default_max_div_sequence = fill(10, length(cell_type_sequence)) # Exemple : chaque type cellulaire peut se diviser jusqu'à 10 fois
        run_simulation(initial_cells, num_steps, grid_size, cell_type_sequence; xml_file = xml_file, max_div_sequence = nothing)
    else
        # Sinon, utiliser le vecteur fourni
        run_simulation(initial_cells, num_steps, grid_size, cell_type_sequence; xml_file = xml_file, max_div_sequence = max_div_sequence)
    end
   

end

function get_generated_form(cell_type_sequence::Vector{Int64})
    xml_file = "cellTypes.xml"  # Vous devrez peut-être ajuster le nom du fichier XML
    num_steps = 25 # Nombre d'étapes de simulation
    grid_size = (30, 30) # Taille de la grille
    cases = Dict(
        1 => [(0, -1)], #Ouest
        2 => [(-1, 0)], #Nord
        3 => [(0, 1)],  #Est
        4 => [(1, 0)],  #Sud
        # 5 => [(1, -1)], #Sud-Ouest
        # 6 => [(-1, -1)],#Nord-Ouest
        # 7 => [(1, 1)], #Sud-Est
        # 8 => [(-1, 1)]#Nord-Est
    )

    initial_cells = CellSetByCoordinates(Dict(
        (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))) =>
            Cell(
                (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))),
                0,
                cell_type_sequence[1],
                cell_type_sequence[1],  # initial_cell_type
                cell_type_sequence[1],
                0,
                0, #initial_nbdiv
                true,
                false,
                1     # current_type_index_in_sequence
            )
        ))

    # Exécuter la simulation
    if max_div_sequence === nothing
        # Si max_div_sequence n'est pas fourni, créer un vecteur par défaut
        # Vous devrez peut-être ajuster cette logique par défaut en fonction de vos besoins.
        #default_max_div_sequence = fill(10, length(cell_type_sequence)) # Exemple : chaque type cellulaire peut se diviser jusqu'à 10 fois
        run_simulation(initial_cells, num_steps, grid_size, cell_type_sequence; xml_file = xml_file, max_div_sequence = nothing)
    else
        # Sinon, utiliser le vecteur fourni
        run_simulation(initial_cells, num_steps, grid_size, cell_type_sequence; xml_file = xml_file, max_div_sequence = max_div_sequence)
    end
   

end
