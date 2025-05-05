using Random
using ColorSchemes
using Plots

# --- Initialisation et paramètres ---
cell_types_to_load = [12]
#cell_types_to_load = [2, 4, 3, 1]
include("struct_cell_env.jl")
include("functions.jl")
include("data_xml.jl")
include("visualization_xml.jl")
# --- Initialisation et paramètres ---

xml_file = "cellTypesChange.xml"

num_steps = 20
grid_size = (30, 30)
max_cell_division = 6




cases = Dict(
    1 => [(0, -1)],
    2 => [(-1, 0)],
    3 => [(0, 1)],
    4 => [(0, -1)],
    5 => [(1, -1)],
    6 => [(-1, -1)],
)






# --- Initial cell configuration ---
initial_cells = CellSetByCoordinates(Dict(
    (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))) =>
        Cell(
            (Int64(floor(grid_size[1] / 2)), Int64(floor(grid_size[2] / 2))),
            0,
            cell_types_to_load[1],
            cell_types_to_load[1],  # initial_cell_type
            cell_types_to_load[1],
            0,
            0, #initial_nbdiv
            true,
            false,
            1     # current_type_index_in_sequence
        )
    ))



# --- Lancement de la simulation ---
run_simulation(initial_cells, num_steps, grid_size, max_cell_division, cell_types_to_load; xml_file)

