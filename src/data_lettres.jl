# src/data.jl

using ColorTypes
using Random
# create_directions_dict W ->[-1, 0]
function create_directions(char::Char, Dim) 
    cases_2d = Dict(
        'Q' => [0, 0],  
        'S' => [1, 0],  
        'W' => [0, -1], 
        'N' => [-1, 0], 
        'E' => [0, 1],  
       
    )
    cases_3d = Dict(
        'E' => [0, 1, 0],
        'W' => [0, -1, 0],
        'N' => [-1, 0, 0],
        'S' => [1, 0, 0],
        'U' => [0, 0, 1],
        'D' => [0, 0, -1],
        'Q' => [0, 0, 0],
        
    )
    
    cases_to_use = Dim == 2 ? cases_2d : cases_3d
    
    # Initialize the result dictionary to store vectors of vectors
    dir_vector=cases_to_use[char]
     
    return dir_vector
end 

# create_directions_dict :WQ -> [[-1, 0], [0, 0]]
function create_directions(cell_type::Symbol, Dim)
    cases_2d = Dict(
        'Q' => [0, 0],   # Neutral
        'S' => [0, -1],  # West
        'W' => [-1, 0],  # North
        'N' => [0, 1],   # East
        'E' => [1, 0],   # South
        'A' => [0, 0], # Assumes A is also a neutral direction
    )
    cases_3d = Dict(
        'E' => [1, 0, 0],
        'W' => [-1, 0, 0],
        'N' => [0, 1, 0],
        'S' => [0, -1, 0],
        'U' => [0, 0, 1],
        'D' => [0, 0, -1],
        'Q' => [0, 0, 0],
        'A' => [0, 0, 0], # Assumes A is also a neutral direction
    )
    
    cases_to_use = Dim == 2 ? cases_2d : cases_3d
    
    # Initialize the result dictionary to store vectors of vectors
    dir_vector = Dict{Symbol, Vector{Vector{Int64}}}()

    
    dir_vector = Vector{Vector{Int64}}()
    for char in string(cell_type)
        if haskey(cases_to_use, char)
            push!(dir_vector, cases_to_use[char])
        else
            @warn "Character '$char' not a recognized direction."
        end
    end
    return dir_vector
end

"""
Loads cell type data with randomly generated colors, a fixed max_cell_division value,
and directions generated from the cell type sequence.
"""
function load_cell_data(model)
    # Define a single dictionary to hold the information for one cell type.
    
    # Create the final dictionary that has one entry for each cell type.
    cell_data  = Dict{Symbol, Dict{String, Any}}()
    
    #cell_data  = Vector{Dict{Symbol, Dict{String, Any}}}()
    for cell_type in model.cell_type_sequence
                model.max_cell_division_functions[cell_type]
        new_cell_info = Dict{String, Any}(
            "directions" => create_directions(cell_type, length(model.grid_size)), 
            "color" => RGB(rand(), rand(), rand()), 
            "max_cell_division_functions" => model.max_cell_division_functions[cell_type])   
    # Add the new element to the main dictionary
    cell_data[cell_type] = new_cell_info  
    end
    return cell_data
end

function set_cell_data(model::CellModel)
    
    model.cell_data = load_cell_data(model)
    
end

