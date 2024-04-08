# Example script 
# 
# Usage: 
# 
#   `$ julia example.jl`
# 
#  Here we will use the two built in distributions and a a user defined [`anonymous function`](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions)
#  to create a fermionic distribution. Then we will use two Gaussians (Normal) for a bosonic distribution.
# 
#  

#md ## Use SynthAC pacakge
using SynthAC

# Create an empty array to add distributions
distributions = []

# Create superposition of distributions. 
AppendDistribution!(distributions,Normal(-1.2,0.5,A=1.2))
AppendDistribution!(distributions,Cauchy(1.0,0.25,A=0.5))
AppendDistribution!(distributions,x -> min(1.0, 5.0 / (x-3.0)^2) )

#md ## Set the parameter for the range we will integrate over. Unfortunately, to allow user generated distributions the range of (-∞,∞) was not possible
Maxω = 10.0

# Generate noisy correlation functions and return a dictionary. 
#
# Noise is generated using formula [`A3`](https://journals.aps.org/prx/abstract/10.1103/PhysRevX.7.041072):
# ```math
# \begin{align*}
# G_{i}= & \left|\bar{G}+\sigma_{i}\right|\\
# \sigma_{j}^{0}= & \text{NormalRand}\left(\mu=0,\sigma=\sigma_{0}\right)\\
# \sigma_{i}= & \frac{\sum_{j}\sigma_{j}^{0}e^{-\left|\tau_{i}-\tau_{j}\right|/\xi}}{\sqrt{\sum_{j}e^{-2\left|\tau_{i}-\tau_{j}\right|/\xi}}}
# \end{align*}
# ```
#
# Parameters fed in
# `distributions`: array of distribution functions
# `10.0`: β
# `0.05`: Δτ
# `true`: fermionic
# `outfile=""`: do not save the dictionary to a file
# `Nbins=50`: Number of bins of noisy data to create
# `AutoCorrelationTime=0.4`: Autocorrelation parameter ξ
#
# Note: fermionic distributions will always normalize to 1.0
dict_data = GenerateCorrelationFunctions(distributions,10.0,0.05,true;outfile="",NBins=50,AutoCorrelationTime=0.4,σ0=0.005,Maxω=Maxω)

# Example outputs
#md ## Distribution generating function. 
A = dict_data["A"]
#md ## τs from 0.0 to β
τs = dict_data["τs"]
#md ## β at which the data was generated
β = dict_data["β"]
#md ## ξ used to generate noisy data
AutoCorrelationTime = dict_data["ξ"]
#md ## σ0 which is fed into the Gaussian random 
σ0 = dict_data["σ0"]
#md ## Binned noisy correlation function of shape [nτ,Nbins]
G_bins = dict_data["Gτ"]
#md ## Noiseless correlation function of shape [nτ]
G_calc = dict_data["Gτ_calc"]

# Calling the distribution function to plot using your favorte plotting software
ωs = LinRange(-Maxω,Maxω,200)


# Set up distributions for bosons
distributions_b = []
AppendDistribution!(distributions_b,Normal(-1.2,0.5,A=1.2))
AppendDistribution!(distributions_b,Normal(4.2,0.5,A=0.5))

# Generate the noisy correlation functions for bosons
# 
# Unlike the fermionic cade we require a symmetry such that A is odd in ω. 
# We do this for you by taking the distribution you enter, enforcing evenness, then multiplying by ω:
# `distribution(ω) = ω * (distribution_in(ω)+distribution_in(-ω))`
#
# We call `GenerateCorrelationFunctions` the same way
dict_data_boson = GenerateCorrelationFunctions(distributions,10.0,0.05,false)
#md ## And your process/plot from here out as you'd like. 