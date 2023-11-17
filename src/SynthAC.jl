module SynthAC

using QuadGK
using FileIO
using Distributions
using Random
using Lehmann

include("main.jl")

export GenerateCorrelationFunctions
export AppendDistribution!


include("distributions.jl")

export Normal
export Cauchy

include("utility.jl")

end
