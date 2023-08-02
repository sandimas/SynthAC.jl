module SynthAC

using QuadGK
using FileIO
using Distributions
using Random


include("main.jl")

export GenerateCorrelationFunctions
export AppendDistribution!


include("distributions.jl")

export Normal
export Cauchy

include("utility.jl")

end
