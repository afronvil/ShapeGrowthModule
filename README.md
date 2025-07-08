Shape_Growth_Populate


This project simulates the growth of shapes using cellular automata principles. It includes tools for initializing, simulating, and visualizing the growth process.

Cell Modeling: Definition and management of cell structures with properties such as type, position, color and division potential.
Environment Management: Representation of a discrete environment (3D grid) for cellular interactions.
Data Loading: Read cell type configurations and properties from XML files.
Growth simulation: Implementation of cell dynamics including division and differentiation according to defined rules.
3D visualization: Tools for visualizing the state of cells at different stages of the simulation, including interactive animations.

Project structure :

The ShapeGrowthModels module is organized as follows:
```
Shape_Growth_Populate/
├── src/
│     ├── ShapeGrowthModels.jl # Main module
│     ├── struct_cell_env.jl # Definition of Cell, CellModel, etc. structures.
│     ├── data_xml.jl # Functions for reading/writing XML files (eg, cellTypes.xml)
│     ├── functions.jl # General utility functions
│     ├── functions_max.jl # Specific utility functions (if distinct)
│     ├── visualization_xml. jl # XML-based visualization functions (if applicable)
│     ├── visualization_3D.jl # Functions for 3D visualization with PlotlyJS
│     └── capture_basin.jl # Specific logic (eg, for catch basin analysis)
├── expl/
│     └── flag.jl # Example script or simulation run
└── xml/
     └── cellTypes130.xml # Example of cell type definition file
```
Installation

To use this module, make sure you have Julia (version 1.6 or higher recommended) installed on your system.

Clone the repository (if it's a Git repository) :
git clone https://github.com/votre_utilisateur/Shape_Growth_Populate.git
cd Shape_Growth_Populate

If it's not a Git repository, simply navigate to the project's root folder.

Launch Julia and install the :

```julia
using Pkg
Pkg.add("Plots")
Pkg.add("Parameters")
Pkg.add("PlotlyJS")
Pkg.add("PlotlyBase")
Pkg.add("ColorSchemes")
Pkg.add("ColorTypes")
Pkg.add("EzXML")
```

In the project's root directory (where the src folder is located), launch Julia :

Une fois dans le REPL Julia, activez l'environnement du projet et installez les dépendances :

```julia
    julia> using Pkg
    julia> Pkg.activate(".") # Activate the current project environment
    julia> Pkg.instantiate() # Installs all dependencies listed in Project.toml
```

How to use :

Here's a basic example of how to run a simulation and visualize the results using the module.

The main example script is expl/flag.jl. You can launch it from the Julia REPL:
```Julia
julia> include("expl/flag.jl")
```

Cell type configuration :

Cell type properties (colors, maximum divisions, growth directions) are defined in XML files, such as xml/cellTypes130.xml. You can modify these files to adapt the behavior of your simulated cells.


Contributions : 

Contributions are welcome! Please open an issue or submit a pull request if you have suggestions or improvements.


License:

This project is licensed under the [MIT License].


Contact: 

If you have any questions or comments, please contact : [Alexandra Fronville alexandra.fronville@univ-brest.fr/ 

https://github.com/afronvil/Shape_Growth_Populate].

I hope you find this README useful! Please feel free to modify it and adapt it further to your specific needs.
