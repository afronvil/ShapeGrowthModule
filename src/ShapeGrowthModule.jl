module ShapeGrowthModule

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

using EzXML
using ColorSchemes
using ColorTypes
using EzXML
using Plots
using Parameters
using PlotlyJS

const PROJECT_ROOT = dirname(dirname(@__FILE__)) 
# Define the path to the XML file
#xml_file = "xml/cellTypes.xml"

const DEFAULT_STROMAL_CELL_TYPE = 99 # <--- AJOUTEZ CETTE LIGNE (utilisez la valeur appropriée pour votre type de cellule stromale par défaut)
const STROMAL_PROXIMITY_DISTANCE = 3


include("struct_cell_env.jl") # Include cell structures first if initialization depends on them
include("utils.jl") 
include("data_lettres.jl")   
include("functions_max.jl")      # Include data loading functions (like load_cell_data) before they are used
include("functions.jl") 
include("pdma_lettres.jl") 
include("visualization.jl") 
include("visualization_2D.jl") # Visualization functions
include("visualization_3D.jl") # 3D visualization functions
#include("capture_basin.jl")

#include("initialization.jl") # Initialization functions that depend on the above files
# If you want to make specific functions or variables accessible directly
# when someone uses `using ShapeGrowthModule`, you should export them here.
# For example, if `initial_cells` or `load_cell_data` are meant to be public:
# export initial_cells, load_cell_data


    export Cell, StromalCell, CellSetByCoordinates, CellModel
    export create_default_initial_cells_dict, initial_cells_dict_default, create_compact_cells
    export run_simulation, cellular_dynamics
    export try_migrate!
    export reconfigure_model_with_sequence!, set_subdivision!
    export visualize_cells_dict # Si vous avez une fonction visualize_cells exportable
    export load_cell_data, get_indexed_subtissues
    export middle, add_initial_cell, create_default_initial_cells_dict, create_initial_stromal_cells_dict
    export get_generated_form, generate_and_sample
    export visualize_history
    export create_directions, create_directions_dict
    export set_cell_data, _restore_cell_state!
    export create_max_cell_divisions_dict
    export set_type_sequence!
    export run!, visualization, set_max_function!, set_type_sequence!
    export visualize_3D_cells
    export visualize_history_3D_plotly_frames
    export visualize_final_state_2D  # <<< Assurez-vous que cette ligne est présente
    export visualize_history_animation_2D # Si elle est dans visualization_2D.jl        

    export calculate_spatial_moments # <<< NOUVEAU : Exporter la fonction de moments


end # module ShapeGrowthModule
