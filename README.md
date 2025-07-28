ShapeGrowthModule

Un module Julia pour la modélisation de la croissance et de la dynamique de forme de cellules. Ce projet permet de simuler la prolifération, la différenciation et les interactions spatiales de divers types cellulaires, offrant des outils pour l'initialisation, la simulation et la visualisation de ces processus complexes.
Fonctionnalités principales

    Modélisation Cellulaire: Définition et gestion de structures cellulaires avec des propriétés telles que le type, la position, la couleur et le potentiel de division.
    Gestion de l'Environnement: Représentation d'un environnement discret (grille 3D) pour les interactions cellulaires.
    Chargement de Données: Lecture des configurations de types cellulaires et de leurs propriétés depuis des fichiers XML.
    Simulation de Croissance: Implémentation de dynamiques cellulaires incluant la division et la différenciation selon des règles définies.
    Visualisation 3D: Outils pour visualiser l'état des cellules à différentes étapes de la simulation, y compris des animations interactives.

Structure du Projet

Le module ShapeGrowthModels est organisé comme suit :

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

    Cloner le dépôt (si c'est un dépôt Git) :
    Bash

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

I hope you find this README useful! Please feel free to modify it and adapt it further to your specific needs.
