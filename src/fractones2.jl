using DifferentialEquations
using LinearAlgebra
using Plots
using Random

# 1. Paramètres
const grid_size = 100  # Taille de la grille (100x100)
const n_GFs = 10       # Nombre de GFs
const PDMA_dim = 4     # [P, D, M, A]

# Répartition des GFs en % pour P, D, M, A
const GF_properties = [
    [0.4, 0.3, 0.2, 0.1], [0.1, 0.6, 0.2, 0.1], [0.3, 0.2, 0.4, 0.1],
    [0.2, 0.2, 0.2, 0.4], [0.5, 0.2, 0.2, 0.1], [0.1, 0.1, 0.7, 0.1],
    [0.3, 0.3, 0.3, 0.1], [0.2, 0.4, 0.1, 0.3], [0.1, 0.2, 0.3, 0.4],
    [0.3, 0.1, 0.1, 0.5]
]

const params = (
    degradation = 0.1,          # Taux de dégradation des GFs
    production = 0.05,          # Taux de production des GFs
    quiescence_threshold = 0.1,  # Seuil pour la quiescence
    GF_indices = [1, 2, 3, 4],   # Index des GFs associés à [P, D, M, A]
    thresholds = [0.5, 0.4, 0.6, 0.3],  # Seuils pour [P, D, M, A]
    steepnesses = [10.0, 8.0, 6.0, 5.0],  # Raideurs pour [P, D, M, A]
)

# 2. Initialisation de la grille
grid = falses(grid_size, grid_size)  # false = vide, true = occupé
F0 = rand(n_GFs, n_GFs) .* 0.5       # Matrice initiale des GFs
PDMA0 = [0.0, 0.0, 0.0, 0.0]        # État initial (quiescence)

# Placer quelques cellules initialement (ex: 10 cellules aléatoires)
for _ in 1:10
    i, j = rand(1:grid_size), rand(1:grid_size)
    grid[i, j] = true
end

# 3. Fonction sigmoïde
function sigmoid(x, threshold, steepness)
    return 1.0 / (1.0 + exp(-steepness * (x - threshold)))
end

# 4. Vérifie si un emplacement est libre autour d'une cellule
function is_space_available(grid, i, j)
    # Vérifie les 8 voisins (Moore neighborhood)
    for di in -1:1, dj in -1:1
        ni, nj = i + di, j + dj
        if 1 ≤ ni ≤ grid_size && 1 ≤ nj ≤ grid_size
            if !grid[ni, nj]
                return true  # Au moins un voisin est libre
            end
        end
    end
    return false  # Tous les voisins sont occupés
end

# 5. Mise à jour de la PDMA avec exclusion spatiale
function update_PDMA(PDMA, F, grid, cell_positions)
    new_grid = copy(grid)
    new_PDMA = copy(PDMA)
    GF_involved = falses(n_GFs, n_GFs)

    # Calculer les contributions totales de chaque GF
    contributions = zeros(PDMA_dim)
    for i in 1:n_GFs, j in 1:n_GFs
        if F[i, j] > 0
            for k in 1:PDMA_dim
                contributions[k] += F[i, j] * GF_properties[j][k]
            end
            GF_involved[i, j] = true
        end
    end

    # Déterminer l'action dominante
    max_contribution = maximum(contributions)
    action = max_contribution > params.quiescence_threshold ? argmax(contributions) : 0

    # Mettre à jour PDMA et la grille
    if action != 0
        # Réinitialiser les GFs impliqués
        for i in 1:n_GFs, j in 1:n_GFs
            if GF_involved[i, j]
                F[i, j] = 0.0
            end
        end

        # Pour chaque cellule, vérifier si elle peut proliférer
        for (i, j) in cell_positions
            if action == 1  # Prolifération
                if is_space_available(grid, i, j)
                    # Trouver un voisin libre aléatoire
                    free_neighbors = []
                    for di in -1:1, dj in -1:1
                        ni, nj = i + di, j + dj
                        if 1 ≤ ni ≤ grid_size && 1 ≤ nj ≤ grid_size && !grid[ni, nj]
                            push!(free_neighbors, (ni, nj))
                        end
                    end
                    if !isempty(free_neighbors)
                        ni, nj = rand(free_neighbors)
                        new_grid[ni, nj] = true  # Nouvelle cellule
                    end
                end
            end
            # Mettre à jour la PDMA de la cellule
            new_PDMA[action] = min(1.0, PDMA[action] + 0.1 * max_contribution)
        end
    else
        # Quiescence
        #new_PDMA = [0.0, 0.0, 0.0, 0.0]
    end

    # Saturation des valeurs (0 ≤ PDMA ≤ 1)
    new_PDMA = clamp.(new_PDMA, 0, 1)
    return new_PDMA, F, new_grid
end

# 6. Simulation
function simulate_system()
    tspan = (0.0, 20.0)
    tsteps = collect(0:0.1:20.0)

    # Positions initiales des cellules
    cell_positions = Tuple{Int, Int}[]
    for i in 1:grid_size, j in 1:grid_size
        if grid[i, j]
            push!(cell_positions, (i, j))
        end
    end

    # Initialisation des historiques
    PDMA_history = Vector{Float64}[]
    F_history = Matrix{Float64}[]
    grid_history = [copy(grid)]

    # Ajouter les états initiaux
    push!(PDMA_history, copy(PDMA0))
    push!(F_history, copy(F0))

    # Simulation
    for i in 2:length(tsteps)
        PDMA_t, F_t, grid_t = update_PDMA(PDMA_history[end], F_history[end], grid_history[end], cell_positions)
        push!(PDMA_history, PDMA_t)
        push!(F_history, F_t)
        push!(grid_history, grid_t)

        # Mettre à jour les positions des cellules
        cell_positions = Tuple{Int, Int}[]
        for i in 1:grid_size, j in 1:grid_size
            if grid_t[i, j]
                push!(cell_positions, (i, j))
            end
        end
    end

    return PDMA_history, F_history, grid_history, tsteps
end

# 7. Exécution et affichage
PDMA_history, F_history, grid_history, tsteps = simulate_system()

# Tracé des résultats
layout = @layout [a{0.5h}; b{0.5h}]

# Tracé de la PDMA
p1 = plot(tsteps, reduce(hcat, PDMA_history)',
          label=["Prolifération" "Différentiation" "Migration" "Apoptosis"],
          xlabel="Temps", ylabel="PDMA",
          title="Dynamique de la PDMA", lw=2, ylims=(0, 1))

# Animation de la grille
anim = @animate for t in 1:10:length(tsteps)
    heatmap(grid_history[t], c=:viridis, title="Grille à t=$(round(tsteps[t], digits=1))",
            xlabel="Position X", ylabel="Position Y", legend=false)
end
gif(anim, "grille_evolution.gif", fps=10)

plot(p1, size=(800, 400))
