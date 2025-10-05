using DifferentialEquations
using LinearAlgebra
using Plots
using Random

# 1. Paramètres et conditions initiales
const n_GFs = 10
const PDMA_dim = 4  # [P, D, M, A]

# Répartition des GFs en % pour P, D, M, A
const GF_properties = [
    [0.4, 0.3, 0.2, 0.1],  # GF1
    [0.1, 0.6, 0.2, 0.1],  # GF2
    [0.3, 0.2, 0.4, 0.1],  # GF3
    [0.2, 0.2, 0.2, 0.4],  # GF4
    [0.5, 0.2, 0.2, 0.1],  # GF5
    [0.1, 0.1, 0.7, 0.1],  # GF6
    [0.3, 0.3, 0.3, 0.1],  # GF7
    [0.2, 0.4, 0.1, 0.3],  # GF8
    [0.1, 0.2, 0.3, 0.4],  # GF9
    [0.3, 0.1, 0.1, 0.5]   # GF10
]

const params = (
    degradation = 0.1,          # Taux de dégradation des GFs
    production = 0.05,          # Taux de production des GFs
    K = [0.9, 0.8, 0.7, 0.3],    # Capacités maximales pour [P, D, M, A]
    quiescence_threshold = 0.1,  # Seuil pour la quiescence
)

# Initialisation
F0 = rand(n_GFs, n_GFs) .* 0.5  # Matrice initiale des GFs (valeurs entre 0 et 0.5)
PDMA0 = [0.0, 0.0, 0.0, 0.0]     # État initial (quiescence)

# 2. Fonction sigmoïde
function sigmoid(x, threshold=0.5, steepness=10.0)
    return 1.0 / (1.0 + exp(-steepness * (x - threshold)))
end

# 3. Dynamique continue de la MEC
function mec_dynamics!(dF, F, p, t)
    production_term = p.production * PDMA0[1]  # Production proportionnelle à P
    dF .= -p.degradation .* F .+ production_term
end

# 4. Mise à jour de la PDMA avec contributions des GFs
function update_PDMA(PDMA, F)
    # Calculer les contributions totales de chaque GF
    contributions = zeros(PDMA_dim)
    GF_involved = falses(n_GFs, n_GFs)  # Matrice pour suivre les GFs impliqués
    GF_contributions = zeros(n_GFs, n_GFs, PDMA_dim)  # Contributions de chaque GF à chaque processus

    for i in 1:n_GFs
        for j in 1:n_GFs
            if F[i, j] > 0
                # Contribution de ce GF aux processus PDMA
                for k in 1:PDMA_dim
                    GF_contributions[i, j, k] = F[i, j] * GF_properties[j][k]
                    contributions[k] += GF_contributions[i, j, k]
                end
                GF_involved[i, j] = true
            end
        end
    end

    # Calculer les pourcentages de contribution de chaque GF à chaque processus
    GF_percentages = [zeros(n_GFs) for _ in 1:PDMA_dim]

    for k in 1:PDMA_dim
        total_contribution = sum(GF_contributions[:, :, k])
        if total_contribution > 0
            # Calculer les pourcentages pour chaque GF
            for j in 1:n_GFs
                GF_percentages[k][j] = sum(GF_contributions[:, j, k]) / total_contribution
            end
        end
    end

    # Déterminer l'action dominante
    max_contribution = maximum(contributions)
    action = max_contribution > params.quiescence_threshold ? argmax(contributions) : 0

    # Mettre à jour PDMA en fonction de l'action dominante
    new_PDMA = copy(PDMA)
    if action != 0
        # Réinitialiser les GFs impliqués
        for i in 1:n_GFs
            for j in 1:n_GFs
                if GF_involved[i, j]
                    F[i, j] = 0.0
                end
            end
        end

        # Activer le processus correspondant
        new_PDMA[action] = min(1.0, PDMA[action] + 0.1 * max_contribution)
    else
        # Quiescence
        new_PDMA = [0.0, 0.0, 0.0, 0.0]
    end

    # Saturation des valeurs
    new_PDMA = clamp.(new_PDMA, 0, params.K)
    return new_PDMA, F, GF_percentages
end

# 5. Simulation
function simulate_system()
    tspan = (0.0, 20.0)
    tsteps = collect(0:0.1:20.0)

    prob = ODEProblem(mec_dynamics!, F0, tspan, params)
    sol_F = solve(prob, Tsit5(), saveat=0.1)

    # Initialisation des historiques
    PDMA_history = Vector{Float64}[]
    F_history = Matrix{Float64}[]
    GF_percentages_history = [Vector{Vector{Float64}}() for _ in 1:PDMA_dim]

    # Ajouter les états initiaux
    push!(PDMA_history, copy(PDMA0))
    push!(F_history, copy(F0))

    # Initialiser les pourcentages
    GF_percentages = [zeros(n_GFs) for _ in 1:PDMA_dim]
    for k in 1:PDMA_dim
        push!(GF_percentages_history[k], copy(GF_percentages[k]))
    end

    # Simulation
    for i in 2:length(tsteps)
        idx = findfirst(==(tsteps[i]), sol_F.t)
        F_t = sol_F.u[idx]
        PDMA_t, F_t_updated, GF_percentages = update_PDMA(PDMA_history[end], F_t)
        push!(PDMA_history, PDMA_t)
        push!(F_history, F_t_updated)

        # Enregistrer les pourcentages
        for k in 1:PDMA_dim
            push!(GF_percentages_history[k], copy(GF_percentages[k]))
        end
    end

    return sol_F, PDMA_history, F_history, GF_percentages_history, tsteps
end

# 6. Exécution et affichage
sol_F, PDMA_history, F_history, GF_percentages_history, tsteps = simulate_system()

# Convertir PDMA_history en matrice
PDMA_matrix = reduce(hcat, PDMA_history)'

# Tracé des résultats
layout = @layout [a{0.6h}; b{0.4h}]

# Tracé de la PDMA
p1 = plot(tsteps, PDMA_matrix,
          label=["Prolifération" "Différentiation" "Migration" "Apoptosis"],
          xlabel="Temps", ylabel="PDMA",
          title="Dynamique de la PDMA", lw=2, ylims=(0, 1))

# Tracé des pourcentages de contribution des GFs à chaque processus
p2 = plot(layout=grid(2, 2), size=(800, 600))

# Pour chaque processus PDMA
process_names = ["Prolifération", "Différentiation", "Migration", "Apoptosis"]
for k in 1:PDMA_dim
    # Extraire les pourcentages pour ce processus
    percentages = reduce(hcat, GF_percentages_history[k])'

    # Tracer les pourcentages des GFs pour ce processus
    plot!(p2[k], tsteps, percentages,
          #label=["GF$j" for j in 1:n_GFs],
          #xlabel="Temps", ylabel="% Contribution",
          title="Contribution des GFs à " * process_names[k],
          legend = false
          #lw=1
          )
end

plot(p1, p2, layout=layout)
