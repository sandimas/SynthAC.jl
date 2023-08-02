@doc raw"""
    GenerateCorrelationFunctions(DistributionArray,β,Δτ,fermionic;
                                 outfile="",NBins=100,AutoCorrelationTime=0.5,
                                 σ0=0.005,Maxω=10.0)

Generates synthetic correlation functions from the passed in functions in the distribution array. 
This generates bins of data with correlated errors using the method developed by 
Hui Shao, Yan Qi Qin, Sylvain Capponi, Stefano Chesi, Zi Yang Meng, and Anders W. Sandvik (PHYSICAL REVIEW X 7, 041072 (2017))

# Arguments
- `DistributionArray`: Array of [`Anonymous Functions`](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions)
- `β`: Inverse Temperature
- `Δτ`: Timestep in imaginary time
- `fermionic`: Boolean, true if using fermionic kernel

# Optinal Arguments
- `outfile`: file to save dictionary to. .jld2 format is recommended. `""` for no output file 
- `NBins`: Number of bins of noisy correlation functions to generate
- `AutoCorrelationTime`: Auto correlation length in imaginary time
- `σ0`: Tuneable parameter to increase/decrease variance in correlation functions
- `Maxω`: range to integrate over. (-∞,∞) is not yet supported, and exponential values in kernels limit range possible 

# Returns
`Dict{String,Any}(...)` containing the keys
- `"A"`: Anonymous function to generate real axis data
- `"β"`: Inverse temperature
- `"τs"`: Imaginary time grid
- `"ξ"`: Autocorrelation Time
- `"σ0"`: Tuneable uncorrelated standard error parameter    
- `"G"`: Array of dimensions [size(τs,1),NBins]
- `"G_calc"`: Reference correlation function without noise
"""
function GenerateCorrelationFunctions(DistributionArray,β,Δτ,fermionic;
                                 outfile="",NBins=100,AutoCorrelationTime=0.5,σ0=0.005,Maxω=10.0)
    nτ = trunc(Int,β/Δτ)+1
    τs = LinRange(0.0,β,nτ)
    
    total_dist = MergeDistributions(DistributionArray)
    
    total_dist= NormalizeDistributions(total_dist,fermionic,Maxω)
    
    G_calc = CalculateCorrelationFunctions(total_dist,τs,β,fermionic,Maxω)

    G_bins = AddNoise(G_calc,NBins,AutoCorrelationTime,σ0,τs)

    if fermionic
        out_dist = x -> total_dist(x)
    else
        out_dist = x -> x*(total_dist(x)+total_dist(-x))
    end

    out_dict = Dict{String,Any}(
        "A" => out_dist,
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

@doc raw"""
    AppendDistribution!(DistributionArray,Distribution)

Appends a new anonymous function to array of anonymous functions

# Arguments
- `DistributionArray`: Array to append anonymous function to. May be empty array
- `Distribution`: Anonymous function to apped
"""
function AppendDistribution!(DistributionArray,Distribution)
    push!(DistributionArray,Distribution)
end

