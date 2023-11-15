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
- `Nωn`: Number of Matsubara frequency points
- `Blurtype`: Either `"gamma"` or `"absgauss"`. `"gamma"` uses a gamma distribution which does not go below zero. `"absgauss"` uses a normal distribution and takes the absolute value 

# Returns
`Dict{String,Any}(...)` containing the keys
- `"A"`: True distribution
- `"ωs": Grid of ω values for A
- `"β"`: Inverse temperature
- `"τs"`: Imaginary time grid
- `"ωns"`: Matsubara frequency grid
- `"ξ"`: Autocorrelation Time
- `"σ0"`: Tuneable uncorrelated standard error parameter    
- `"Gτ"`: Array of dimensions [NBins,size(τs,1)]
- `"Gτ_calc"`: Reference correlation function without noise
- `"Gωn"`: Array of dimensions [NBins,size(ωns,1)]
- `"Gωn_calc"`: Reference correlation function without noise

"""
function GenerateCorrelationFunctions(DistributionArray,β,Δτ,fermionic;
                                 outfile="",NBins=100,AutoCorrelationTime=0.5,
                                 σ0=0.005,Maxω=10.0,Blurtype="gamma",Nωn = 200)
    # Get matsubara arrays
    nτ = trunc(Int,β/Δτ)+1
    τs = LinRange(0.0,β,nτ)
    ωns = get_ωn(Nωn,β,fermionic)

    # Merge functions
    total_dist = MergeDistributions(DistributionArray)
    
    total_dist= NormalizeDistributions(total_dist,fermionic,Maxω)
    
    Gτ_calc = CalculateCorrelationFunctionsτ(total_dist,τs,β,fermionic,Maxω)

    Gτ_bins = AddNoise(Gτ_calc,NBins,AutoCorrelationTime,σ0,τs,Blurtype,fermionic)

    if fermionic
        Gω_calc = τ_to_ωn(Gτ_calc, τs,Nωn)
    else
        Gω_calc = CorrelationFunctionsBosonic_ωn(total_dist,ωns,Maxω)
    end
    
    # Gω_bins = zeros(ComplexF64,(NBins,Nωn))
    Gω_bins = AddNoise(Gω_calc,NBins,AutoCorrelationTime * 10 * π / β,σ0 * 0.1,ωns,"gauss",false)

    # for bin in 1:NBins
    #     Gω_bins[bin,:] = τ_to_ωn(Gτ_bins[bin,:], τs,fermionic,Nωn)
    # end

    if fermionic
        out_dist = x -> total_dist(x)
    else
        out_dist = x -> x*(total_dist(x)+total_dist(-x))
    end
    ωs = LinRange(-Maxω,Maxω,401)
    A_out = out_dist.(ωs)

    out_dict = Dict{String,Any}(
        "A" => A_out,
        "ωs" => ωs,
        "τs" => τs,
        "ξ" => AutoCorrelationTime,
        "β" => β,
        "σ0" => σ0,
        "Gτ" => Gτ_bins,
        "Gτ_calc" => Gτ_calc,
        "Gω" => Gω_bins,
        "Gω_calc" => Gω_calc,
        "ωns" => ωns
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

