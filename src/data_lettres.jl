# src/data_lettres.jl

"""
Converts a cell type symbol and dimension into a list of direction vectors.
It uses a single 3D case dictionary and slices the resulting vector (e.g., [1, 1, 0] becomes [1, 1] for Dim=2).
Returns a dictionary where the key is the input cell_type and the value is the list of vectors.
"""
function create_directions_dict(cell_type::Symbol, Dim::Int64)::Dict{Symbol, Vector{Vector{Int64}}}
    # Dictionaries mapping direction codes (as strings) to coordinate vectors (defined in 3D)
    cases = Dict{String, Vector{Int64}}(
        # Base directions (3D)
        "Q" => zeros(Int64, 3),   # Quiescence/Neutral
        "A" => zeros(Int64, 3),   # Apoptosis
        "N" => [0, 1, 0],         # North
        "S" => [0, -1, 0],        # South
        "E" => [1, 0, 0],         # East
        "W" => [-1, 0, 0],        # West
        "U" => [0, 0, 1],         # Up (3D only)
        "D" => [0, 0, -1],        # Down (3D only)

        # 2D/3D combined with Q
        "NQ" => [0, 1, 0], "SQ" => [0, -1, 0], "EQ" => [1, 0, 0],
        "WQ" => [-1, 0, 0], "UQ" => [0, 0, 1], "DQ" => [0, 0, -1],

        # 2D/3D Diagonals
        "NE" => [1, 1, 0], "SE" => [1, -1, 0], "NW" => [-1, 1, 0], "SW" => [-1, -1, 0],

        # 3D Face-diagonals
        "NU" => [0, 1, 1], "ND" => [0, 1, -1], "SU" => [0, -1, 1], "SD" => [0, -1, -1],
        "EU" => [1, 0, 1], "ED" => [1, 0, -1], "WU" => [-1, 0, 1], "WD" => [-1, 0, -1],
        
        # 3D Corner-diagonals
        "NEU" => [1, 1, 1], "NED" => [1, 1, -1], "SEU" => [1, -1, 1], "SED" => [1, -1, -1],
        "NWU" => [-1, 1, 1], "NWD" => [-1, 1, -1], "SWU" => [-1, -1, 1], "SWD" => [-1, -1, -1],
    )
    
    direction_string = string(cell_type)
    
    # Clean the string by keeping only capital letters, digits, and underscores
    direction_string = filter(c -> isuppercase(c) || c == '_' || isdigit(c), direction_string)
    
    # The cell type is split into components (instructions)
    instructions = split(direction_string, '_')
    
    dir_vectors = Vector{Vector{Int64}}()

    for instruction in instructions
        # Skip empty strings that might result from splitting (e.g., if input was "__W__")
        if isempty(instruction)
            continue
        end

        if haskey(cases, instruction)
            full_vector = cases[instruction]
            
            # Slice the vector to match the dimension (e.g., [1, 1, 0] becomes [1, 1] for Dim=2)
            dir_vector = full_vector[1:Dim] 
            push!(dir_vectors, dir_vector)
        else
            # Only warn if the instruction is not empty after filtering
            @warn "Instruction '$instruction' (from type $cell_type) not recognized for $Dim D. Using zero vector."
            # We don't push the zero vector here to keep the list clean, but we handle the empty case below.
            # push!(dir_vectors, zeros(Int64, Dim)) <-- Removed from here
        end
    end
    
    # --- FIX BoundsError ---
    # If no valid directions were found (either due to corruption or Q/A type)
    # the downstream code expects a non-empty vector to index. We provide the Quiescence vector.
    if isempty(dir_vectors)
        # Quiescence/Neutral vector (zeros) matching the current dimension
        push!(dir_vectors, zeros(Int64, Dim))
    end
    # --- END FIX ---
    
    return Dict(cell_type => dir_vectors)
end


"""
Loads cell type data with randomly generated colors, a fixed max_cell_division value,
and directions generated from the cell type sequence.
"""
function load_cell_data(model)
    # Create the final dictionary that has one entry for each cell type.
    cell_data  = Dict{Symbol, Dict{String, Any}}()
    
    # Define a default function that returns a maximum division count (e.g., 5)
    default_max_div_func = (x) -> 5

    for cell_type in model.cell_type_sequence
        # FIX: Use 'get' to safely retrieve the function reference, providing a default 
        max_div_func = get(model.max_cell_division_functions, cell_type, default_max_div_func)
        println("----------------------max_div_func", max_div_func)
        new_cell_info = Dict{String, Any}(
            "directions" => create_directions_dict(cell_type, length(model.grid_size)), 
            "color" => RGB(rand(), rand(), rand()), 
            "max_cell_division_functions" => max_div_func
        )   
        # Add the new element to the main dictionary
        cell_data[cell_type] = new_cell_info  
    end
    return cell_data
end

function set_cell_data(model::CellModel)
    
    model.cell_data = load_cell_data(model)
    
end
