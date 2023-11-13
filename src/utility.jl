
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
            dist = x -> ifelse(x≈0.0,2.0 *total_dist(x)/β,  x * (exp_τ(τ)(x)+exp_τ(β-τ)(x)) * (total_dist(x)+total_dist(-x)) * n_bose(β)(x))
        end
        G_calc[τi], _ = quadgk(x-> dist(x),-Maxω,Maxω)
    end
    return G_calc
end



function AddNoise(G_calc,NBins,AutoCorrelationTime,σ0,τs,Blurtype)
    nτ = size(G_calc,1)
    G_binned = zeros(eltype(G_calc),(NBins,nτ))
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
        G_norm = norm(G_calc)
        αs, θs = get_Γ_params((G_norm),σ0)
        for bin in 1:NBins
            σ0js = zeros(Float64,nτ)
            σs = zeros(Float64,nτ)    
            for (τi, τ) in enumerate(τs)
                σ0js[τi] = rand(rng,Distributions.Gamma(αs[τi],θs[τi])) - (G_norm[τi])
            end
            for (τi, τ) in enumerate(τs)
                denom = sqrt(sum(exp.(-2 .* abs.(τ .- τs) ./ ξ)))
                num = sum(σ0js .* exp.(-abs.(τ .- τs) ./ ξ))
                σs[τi] = num/denom
            end
            G_binned[bin,:] = G_calc .+ (σs .* G_calc ./ G_norm)
        end
    end   
    
    return G_binned
end

function norm(a)
    return @. sqrt(real(a)^2 + imag(a)^2)
end



function get_Γ_params(G_calc,σ0)
    # keep σ < G_calc or distro goes bad
    σs = zeros(Float64,size(G_calc,1))
    σs = min.(σ0,real.(G_calc) .* 0.5)
    # σs .= σ0
    θs = σs.^2 ./ G_calc
    αs = G_calc.^2 ./ σs.^2
    return αs, θs
end

function get_ωn(nωn,β,fermionic)
    ωns = 2.0 .* collect(0:nωn-1)
    if fermionic
      ωns = ωns .+ 1
    end  
    ωns = ωns .* (π/β )
    return ωns
end



function τ_to_ωn(G,τs, isFermi, Nωn)
    β=τs[end]
    
    Euv = 1.0
    rtol = 1e-12
    symmetry = :none

    dlr = DLRGrid(Euv, β, rtol, isFermi, symmetry)

    ngrid = collect(0:Nωn-1)

    Gωn = tau2matfreq(dlr, -G, ngrid, τs)

    return Gωn
end