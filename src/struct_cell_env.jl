
# --- Structures de données ---
mutable struct Cell
    coordinates::Tuple{Int64, Int64}
    timer::Int64
    cell_type::Int64
    initial_cell_type::Int64
    last_division_type::Int64
    nbdiv::Int64
    initial_nbdiv::Int64
    is_alive::Bool
    has_proliferated_this_step::Bool
  
    current_type_index_in_sequence::Union{Int64, Nothing} # Ajout de ce champ
end

Cell(coordinates, timer, cell_type, initial_cell_type, last_division_type, nbdiv, initial_nbdiv, is_alive, has_proliferated_this_step, current_type_index_in_sequence) =
    Cell(coordinates, timer, cell_type, initial_cell_type, last_division_type, nbdiv, initial_nbdiv, is_alive, has_proliferated_this_step, current_type_index_in_sequence) # Initialisation alternative

mutable struct CellSetByCoordinates
    cells::Dict{Tuple{Int64, Int64}, Cell}
end
CellSetByCoordinates() = CellSetByCoordinates(Dict{Tuple{Int64, Int64}, Cell}())

