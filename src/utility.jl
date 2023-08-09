
function MergeDistributions(DistributionArray)
    total_dist = x -> 0
    for (disti, dist) in enumerate(DistributionArray)
        total_dist  = let total_dist =total_dist; x -> total_dist(x) + dist(x); end
    end
    return total_dist
end

function NormalizeDistributions(Distribution,fermionic,Maxω)
    if fermionic
        zeroth_moment, err = quadgk(x -> Distribution(x),-Maxω,Maxω)
        return x -> Distribution(x) / zeroth_moment
    else
        return x -> Distribution(x)
    end
end

function CalculateCorrelationFunctions(total_dist,τs,β,fermionic,Maxω)
    G_calc = zeros(Float64,size(τs,1))
    for (τi, τ) in enumerate(τs)
        dist = x -> 0
        if fermionic
            dist = x -> total_dist(x) *  exp_τ(τ)(x) * n_fermi(β)(x)    
        else
            dist = x -> ifelse(x≈0.0,total_dist(x)/β, 0.5 * x * (exp_τ(τ)(x)+exp_τ(β-τ)(x)) * (total_dist(x)+total_dist(-x)) * n_bose(β)(x))
        end
        G_calc[τi], _ = quadgk(x-> dist(x),-Maxω,Maxω)
    end
    return G_calc
end

function AddNoise(G_calc,NBins,AutoCorrelationTime,σ0,τs,Blurtype)
    nτ = size(G_calc,1)
    G_binned = zeros(Float64,(NBins,nτ))
    ξ = AutoCorrelationTime
    seed = abs(rand(Int))
    rng = Xoshiro(seed)
   
    if Blurtype == "absgauss"
        for bin in 1:NBins
            σ0js = zeros(Float64,nτ)
            σs = zeros(Float64,nτ)    
            σ_min = min.(σ0,G_calc .* 0.5)
            for (τi, τ) in enumerate(τs)
                σ0js[τi] = rand(rng,Distributions.Normal(0.0,σ_min[τi]))
            end
            for (τi, τ) in enumerate(τs)
                denom = sqrt(sum(exp.(-2 .* abs.(τ .- τs) ./ ξ)))
                num = sum(σ0js .* exp.(-abs.(τ .- τs) ./ ξ))
                σs[τi] = num/denom
            end
            G_binned[bin,:] = abs.(G_calc .+ σs)
        end
    else
        
        αs, θs = get_Γ_params(G_calc,σ0)
        for bin in 1:NBins
            σ0js = zeros(Float64,nτ)
            σs = zeros(Float64,nτ)    
            for (τi, τ) in enumerate(τs)
                σ0js[τi] = rand(rng,Distributions.Gamma(αs[τi],θs[τi])) - G_calc[τi]
            end
            for (τi, τ) in enumerate(τs)
                denom = sqrt(sum(exp.(-2 .* abs.(τ .- τs) ./ ξ)))
                num = sum(σ0js .* exp.(-abs.(τ .- τs) ./ ξ))
                σs[τi] = num/denom
            end
            G_binned[bin,:] = G_calc .+ σs
        end
    end   
    
    
    return G_binned
end

function get_Γ_params(G_calc,σ0)
    # keep σ < G_calc or distro goes bad
    σs = zeros(Float64,size(G_calc,1))
    σs = min.(σ0,G_calc .* 0.5)
    # σs .= σ0
    θs = σs.^2 ./ G_calc
    αs = G_calc.^2 ./ σs.^2
    return αs, θs
end
