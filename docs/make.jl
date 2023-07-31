using Documenter
using SynthAC
using Literate



# example_names = ["fermion_greens"]#,"phonon_greens"]
# example_literate_sources = [joinpath(@__DIR__,"src/examples/"*name*".jl") for name in example_names]
# example_script_destinations = [joinpath(@__DIR__,"../scripts") for name in example_names]
# example_documentation_destination = joinpath(@__DIR__,"build/examples")
# example_documentation_paths = ["examples/$name.md" for name in example_names]



# DocMeta.setdocmeta!(SmoQyDEAC, :DocTestSetup, :(using SmoQyDEAC); recursive=true)

# for i in eachindex(example_names)
#     Literate.markdown(example_literate_sources[i], example_documentation_destination; 
#                       execute = false,
#                       documenter = true)
#     Literate.script(example_literate_sources[i], example_script_destinations[i])
# end



makedocs(
    sitename = "SynthAC",
    format = Documenter.HTML(),
    modules = [SynthAC],
    authors="James Neuhaus <jneuhau1@utk.edu>",
    repo="https://github.com/sandimas/SynthAC.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://sandimas.github.io/SynthAC.jl/",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    #     "Derivations" => "derivations.md",
    ],
    draft = false

    
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/sandimas/SynthAC.jl",
    devbrach="main",

)
