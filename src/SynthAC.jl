module SynthAC

using QuadGK
using FileIO
using Distributions
using Random

# Write your package code here.
include("main.jl")

export GenerateCorrelationFunctions
export AppendDistribution!


include("distributions.jl")

export Normal
export Cauchy

include("utility.jl")

end
