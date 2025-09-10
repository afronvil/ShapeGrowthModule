# src/data_xml.jl

using ColorTypes
using EzXML
"""
Loads cell type colors from an XML file.
Handles file reading and data format errors.
"""


function load_cell_data(xml_file::String, cell_type_sequence::Vector{Symbol})
    if !isfile(xml_file)
        error("XML file not found: $full_xml_path. Please check the path and structure of the 'xml' folder.")
    end
    cell_data = Dict{Symbol, Dict{String, Any}}()
    
    try
        doc = readxml(xml_file)
        gene = root(doc)
       
        if gene === nothing
            error("XML file contains no 'gene' root element.")
        end
        for genome in findall("genome", gene)
            # Sélectionner les éléments 'cellType' à l'intérieur de chaque 'genome'
            for cell_type in findall("cellType", genome)
                
                type_id = Symbol(cell_type["type"])
                if type_id in cell_type_sequence
                    try
                        # Extraire les attributs de couleur
                        color0 = parse(Float64, cell_type["color0"]) 
                        color1 = parse(Float64, cell_type["color1"]) 
                        color2 = parse(Float64, cell_type["color2"]) 
                        max_cell_division = parse(Int64, cell_type["max_cell_division"])
                        directions = Int64[]
                        
                        for i in 0:5  # Correction : Utiliser 0:(nb_dirs - 1)
                            dir = parse(Int64, cell_type["dir$i"]) # Convertir en Float64
                            push!(directions, dir)    
                        end
                        
                        cell_data[type_id] = Dict("directions" => directions, "color" => RGB(color0, color1, color2), "max_cell_division" => max_cell_division)
                    catch e
                        @warn "Error reading cellType node attributes for type $type_id:"
                        cell_data[type_id] = Dict("directions" => Int64[],"color" => RGB(0.0, 0.0, 0.0),0)
                    end
                end
            end
        end
    catch e
        error("Error loading cell colors from $xml_file : $e")
    end

    return cell_data
end

function set_cell_data(model::CellModel, xml_file_path::String)
    model.cell_data = load_cell_data(xml_file_path, model.cell_type_sequence)
end