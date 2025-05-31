using ShapeGrowthModels
using Random

# Nombre de fonctions fct à générer
num_fct = 8 # Pour 8 "directions" potentielles

# Centre de la grille
center_x = 50
center_y = 50

function get_angle(cell::ShapeGrowthModels.Cell)
    dx = cell.coordinates[1] - center_x
    dy = cell.coordinates[2] - center_y
    return atan(dy, dx) + pi # Angle entre 0 et 2pi
end

function get_distance(cell::ShapeGrowthModels.Cell)
    dx = cell.coordinates[1] - center_x
    dy = cell.coordinates[2] - center_y
    return sqrt(dx^2 + dy^2)
end

# Génération automatique du vecteur de fonctions fct basées sur l'angle et la distance
fct = [function(cell::ShapeGrowthModels.Cell)
           angle_cell = get_angle(cell)
           distance_cell = get_distance(cell)
           # Favoriser la croissance à certaines "distances" et "angles"
           radial_factor = exp(-(distance_cell - (i * 10))^2 / 50) # Pics de croissance à des distances multiples de 10
           angular_factor = 0.5 + 0.5 * cos(angle_cell * num_fct - i * pi / 2) # Croissance favorisée dans certaines directions

           return round(5 + 5 * radial_factor * angular_factor)
       end for i in 1:num_fct]

num_steps = 150
xml_file="../xml/cellTypes130.xml"

function generate_cell_type_sequence(num_elements::Int, max_type::Int)
    cell_type_sequence = rand(Random.default_rng(), 1:max_type, num_elements)
    println("Vecteur aléatoire généré pour cell_type_sequence : ", cell_type_sequence)
    return cell_type_sequence
end

cell_type_sequence = generate_cell_type_sequence(50, num_fct) # Plus longue séquence pour observer la forme

initial_cells = ShapeGrowthModels.create_default_initial_cells((50, 50), cell_type_sequence[1])

model = ShapeGrowthModels.CellModel(initial_cells; xml_file=xml_file, cell_type_sequence=cell_type_sequence)

for i in 1:length(fct)
    ShapeGrowthModels.set_max_function!(model, i, fct[i])
end

ShapeGrowthModels.run!(model)

script_name = splitext(basename(@__FILE__))[1]
output_directory = "../expl/"
filename = joinpath(output_directory, "radial_angular_fct_$(script_name).gif")

ShapeGrowthModels.visualize(model,filename)