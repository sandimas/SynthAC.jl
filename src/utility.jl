
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

function AddNoise(G_calc,NBins,AutoCorrelationTime,σ0,τs)
    nτ = size(G_calc,1)
    G_binned = zeros(Float64,(NBins,nτ))
    ξ = AutoCorrelationTime
    seed = abs(rand(Int))
    rng = Xoshiro(seed)
   
    for bin in 1:NBins
        σ0js = zeros(Float64,nτ)
        σs = zeros(Float64,nτ)    
        for (τi, τ) in enumerate(τs)
            σ0js[τi] = rand(rng,Distributions.Normal(0.0,σ0))
        end
        for (τi, τ) in enumerate(τs)
            denom = sqrt(sum(exp.(-2 .* abs.(τ .- τs) ./ ξ)))
            num = sum(σ0js .* exp.(-abs.(τ .- τs) ./ ξ))
            σs[τi] = num/denom
        end
        G_binned[bin,:] = abs.(G_calc .+ σs)
    end    
    return G_binned
end
