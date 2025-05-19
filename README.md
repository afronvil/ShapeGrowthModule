# Shape Growth Module

This project simulates the growth of shapes using cellular automata principles. It includes tools for initializing, simulating, and visualizing the growth process.

## Prerequisites

Before running the code, ensure you have the following installed:

- **Julia**: Download and install Julia from [https://julialang.org/downloads/](https://julialang.org/downloads/).
- Required Julia packages:
  - `Plots`
  - `ColorSchemes`
  - `ColorTypes`
  - `EzXML`

You can install these packages by running the following commands in the Julia REPL:
```julia
using Pkg
Pkg.add("Plots")
Pkg.add("ColorSchemes")
Pkg.add("ColorTypes")
Pkg.add("EzXML")
```

## Project Structure
The project contains the following files:

cellTypes.xml: Defines the types of cells and their properties.
data_xml.jl: Handles data parsing and XML processing.
Frenchflag.jl: Implements the French flag problem logic.
functions.jl: Contains utility functions for the simulation.
initialization.jl: Handles the initialization of the simulation environment.
simulation.jl: Main script to run the simulation.
struct_cell_env.jl: Defines the structure of cells and their environment.
visualization.jl: Handles visualization of the simulation results.
visualization_xml.jl: Manages XML-based visualization.

## How to Run
1. Clone or download the repository to your local machine.

2. Open a terminal and navigate to the project directory.

3. Launch Julia:

4. Load the main simulation script:
```julia
include("simulation.jl")
```

6. Run the simulation by calling the get_generated_form function:
 ```julia
get_generated_form([1, 2, 3, 1], [5, 10, 5, 8])
```
or if you want to use the values of the xml file:
```julia
get_generated_form([1, 2, 3, 1])
```

- The first argument is the sequence of cell types.
- The second argument is the maximum number of divisions for each type which is optinnal if you use the values of the xml file.

 6. View the results, which will be displayed as a heatmap.


## Customization
You can modify the simulation parameters by editing the arguments passed to get_generated_form or by adjusting the configuration in cellTypes.xml.

## Troubleshooting
Ensure all required files are in the project directory.
Verify that all dependencies are installed.
Check the syntax and structure of cellTypes.xml if XML-related errors occur.
License
This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgments
This project was developed to explore shape growth using computational models.


