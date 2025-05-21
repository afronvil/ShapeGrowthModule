module ShapeGrowthModels
# This module contains the implementation of various shape growth models
# and their associated functions.
# It includes the following files:
# - functions.jl: Contains utility functions for the models.
# - data_xml.jl: Contains functions for reading and writing XML data files.
# - visualization_xml.jl: Contains functions for visualizing the models.
# - struct_cell_env.jl: Contains the structure for cells and their properties.

# It's good practice to include files that define types and core functionalities first.
# If initialization.jl depends on functions from data_xml.jl or types from struct_cell_env.jl,
# those files must be included before initialization.jl.

include("struct_cell_env.jl") # Include cell structures first if initialization depends on them
include("data_xml.jl")        # Include data loading functions (like load_cell_data) before they are used
include("initialization.jl")  # Now initialization.jl can safely call load_cell_data

include("functions.jl")       # General utility functions
include("visualization_xml.jl") # Visualization functions

# If you want to make specific functions or variables accessible directly
# when someone uses `using ShapeGrowthModels`, you should export them here.
# For example, if `initial_cells` or `load_cell_data` are meant to be public:
# export initial_cells, load_cell_data

end # module ShapeGrowthModels
