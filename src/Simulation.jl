module SimulationModule

include("initialisation.jl")



# # --- Lancement de la simulation ---

function run_simulation_with_sequence(cell_type_sequence::Vector{Int64})

result = run_simulation(initial_cells, num_steps, grid_size, cell_types_sequence; xml_file)

end

end # module Simulation

