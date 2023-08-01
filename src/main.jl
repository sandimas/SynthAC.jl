

function GenerateCorrelationFunctions(DistributionArray,β,Δτ,fermionic;
                                 outfile="",NBins=100,AutoCorrelationTime=0.5,σ0=0.005,Maxω=10.0)
    nτ = trunc(Int,β/Δτ)+1
    τs = LinRange(0.0,β,nτ)
    
    total_dist = MergeDistributions(DistributionArray)
    
    total_dist= NormalizeDistributions(total_dist,fermionic,Maxω)
    
    G_calc = CalculateCorrelationFunctions(total_dist,τs,β,fermionic,Maxω)

    G_bins = AddNoise(G_calc,NBins,AutoCorrelationTime,σ0,τs)


    out_dict = Dict{String,Any}(
        "A" => total_dist,
        "τs" => τs,
        "ξ" => AutoCorrelationTime,
        "β" => β,
        "σ0" => σ0,
        "G" => G_bins,
        "G_calc" => G_calc
    )
    if outfile != ""
        save(outfile,out_dict)
    end
    return out_dict
end

function AppendDistribution!(DistributionArray,Distribution)
    push!(DistributionArray,Distribution)
end

