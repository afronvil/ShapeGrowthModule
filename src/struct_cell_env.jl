# src/struct_cell_env.jl

using Parameters 


@with_kw mutable struct Cell
    coordinates::Vector{Int64}
    timer::Int64 = 0
    cell_type::Symbol
    initial_cell_type::Symbol
    last_division_type::Symbol
    nbdiv::Int64 =6
    max_divisions::Int64
    is_alive::Bool = true
    has_proliferated_this_step::Bool = false
    current_type_index_in_sequence::Int64 = 1
end

@with_kw mutable struct StromalCell
    coordinates::Vector{Int64}
    timer::Int64 = 0
    cell_type::Symbol
    initial_stromal_cell_type::Symbol
    last_division_type::Symbol
    nbdiv::Int64 = 0
    max_divisions::Int64 = 0
    is_alive::Bool = true
    has_proliferated_this_step::Bool = false
end

struct SystemState
    cells::Dict{Vector{Int64}, Cell}
    stromal_cells::Union{Dict{Vector{Int64}, StromalCell}, Nothing}
    time::Float64
end

mutable struct CellSetByCoordinates
    cells::Dict{Vector{Int64}, Cell}
end

CellSetByCoordinates() = CellSetByCoordinates(Dict{Vector{Int64}, Cell}())



@with_kw mutable struct CellModel
    cell_type_sequence::Vector{Symbol}
    grid_size::Vector{Int64} 
    Dim::Int64 =length(grid_size)
    # Ajout d'une valeur par défaut pour que ce champ ne soit plus requis
    cell_data::Dict{Symbol, Dict{String, Any}} = Dict{Symbol, Dict{String, Any}}()
    cells::Dict{Vector{Int64}, Cell} = Dict{Vector{Int64}, Cell}()
    stromal_cells::Union{Dict{Vector{Int64}, StromalCell}, Nothing} = nothing
    dist_cellule_fibroblast::Float64 = 6.00
    current_time::Int64 = 0
    max_division_functions::Dict{Symbol, Function} = Dict{Symbol, Function}()
    migration_functions::Dict{Int64, Function} = Dict{Int64, Function}()
    history::Vector{NamedTuple{(:cells, :stromal_cells), Tuple{Dict{Vector{Int64}, Cell}, Dict{Vector{Int64}, StromalCell}}}} = Vector{NamedTuple{(:cells, :stromal_cells), Tuple{Dict{Vector{Int64}, Cell}, Dict{Vector{Int64}, StromalCell}}}}()
end
