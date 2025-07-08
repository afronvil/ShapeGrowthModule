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

Lancer Julia et installer les dépendances :

```julia
using Pkg
Pkg.add("Plots")
Pkg.add("ColorSchemes")
Pkg.add("ColorTypes")
Pkg.add("EzXML")
```

Dans le répertoire racine du projet (là où se trouve le dossier src), lancez Julia :
Bash

julia

Une fois dans le REPL Julia, activez l'environnement du projet et installez les dépendances :
Julia

    julia> using Pkg
    julia> Pkg.activate(".") # Active l'environnement du projet actuel
    julia> Pkg.instantiate() # Installe toutes les dépendances listées dans Project.toml

    (Assurez-vous qu'un fichier Project.toml existe et liste les dépendances comme EzXML, ColorSchemes, ColorTypes, Plots, Parameters, PlotlyJS, PlotlyBase).

Utilisation :

Voici un exemple basique de comment lancer une simulation et visualiser les résultats en utilisant le module.

Le script d'exemple principal est expl/flag.jl. Vous pouvez le lancer depuis le REPL Julia :
Julia

julia> include("expl/flag.jl")


Configuration des Types Cellulaires :

Les propriétés des types cellulaires (couleurs, divisions maximales, directions de croissance) sont définies dans des fichiers XML, comme xml/cellTypes130.xml. Vous pouvez modifier ces fichiers pour adapter le comportement de vos cellules simulées.


Contributions : 

Les contributions sont les bienvenues ! Veuillez ouvrir une issue ou soumettre une pull request si vous avez des suggestions ou des améliorations.


Licence :

Ce projet est sous licence [MIT License].


Contact : 

Pour toute question ou commentaire, veuillez contacter [Alexandra Fronville alexandra.fronville@univ-brest.fr/ https://github.com/afronvil/Shape_Growth_Populate].

J'espère que ce README vous sera utile ! N'hésitez pas à le modifier et à l'adapter davantage à vos besoins spécifiques.
