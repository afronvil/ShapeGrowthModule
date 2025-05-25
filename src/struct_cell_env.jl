# ShapeGrowthModels/src/struct_cell_env.jl

mutable struct Cell
    coordinates::Tuple{Int64, Int64}
    timer::Int64
    cell_type::Int64
    initial_cell_type::Int64
    last_division_type::Int64
    nbdiv::Int64
    max_divisions::Int64
    is_alive::Bool
    has_proliferated_this_step::Bool
    current_type_index_in_sequence::Union{Int64, Nothing}
end



mutable struct CellSetByCoordinates
    cells::Dict{Tuple{Int64, Int64}, Cell}
end
CellSetByCoordinates() = CellSetByCoordinates(Dict{Tuple{Int64, Int64}, Cell}())

mutable struct CellModel
    xml_file::String
    cell_data::Dict{Int64, Dict{String, Any}}
    grid_size::Tuple{Int64, Int64}
    cells::CellSetByCoordinates
    current_time::Int64
    type_sequence::Vector{Int64}
    subdivision_rules::Dict{Int64, Function}
    max_cell_divisions_dict::Dict{Int64, Function}
    proliferation_directions::Dict{Int64, Vector{Tuple{Int64, Int64}}}
    history::Vector{CellSetByCoordinates} # <-- Ajout du champ history ici

    function CellModel(initial_cells::CellSetByCoordinates = create_default_initial_cells();
                       xml_file::String = "cellTypes.xml",
                       grid_size::Tuple{Int64, Int64} = (100, 100))
        cell_data = load_cell_data(xml_file, Int64[])
        subdivision_rules = Dict{Int64, Function}()
        max_cell_divisions_dict = Dict{Int64, Function}()
        proliferation_directions = Dict{Int64, Vector{Tuple{Int64, Int64}}}()
          # Initialisation du champ history comme un tableau vide
        history = Vector{CellSetByCoordinates}() 
        new(xml_file, cell_data, grid_size, initial_cells, 0, [], subdivision_rules, max_cell_divisions_dict, proliferation_directions,)
    end
end