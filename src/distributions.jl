function Normal(μ,σ;A=1.0)
    return x->(A/sqrt(2*π*σ^2))*exp(-(x-μ)^2/(2*σ^2))
end

function Cauchy(μ,σ;A=1.0)
    return x -> A / (π*σ*(1+((x-μ)/σ)^2))
end

function n_fermi(β)
    return x -> 1.0 / (1+exp(-x*β))
end

function exp_τ(τ)
    return x -> exp(-x*τ)
end

