using SynthAC

distributions = []

AppendDistribution!(distributions,Normal(-1.2,0.5,A=1.2))
AppendDistribution!(distributions,Cauchy(1.0,0.25,A=0.5))
AppendDistribution!(distributions,x -> min(1.0, 5.0 / (x-3.0)^2) )

Maxω = 10.0

dict_data = GenerateCorrelationFunctions(distributions,10.0,0.05,true;outfile="",NBins=50,AutoCorrelationTime=0.4,σ0=0.005,Maxω=Maxω)

A = dict_data["A"]
τs = dict_data["τs"]
β = dict_data["β"]
AutoCorrelationTime = dict_data["ξ"]
σ0 = dict_data["σ0"]
G_bins = dict_data["Gτ"]
G_calc = dict_data["Gτ_calc"]

ωs = LinRange(-Maxω,Maxω,200)

distributions_b = []
AppendDistribution!(distributions_b,Normal(-1.2,0.5,A=1.2))
AppendDistribution!(distributions_b,Normal(4.2,0.5,A=0.5))

dict_data_boson = GenerateCorrelationFunctions(distributions,10.0,0.05,false)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

