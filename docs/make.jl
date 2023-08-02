using SynthAC
using Documenter
using Literate



example_names = ["example"]
example_literate_sources = [joinpath("src/examples/"*name*".jl") for name in example_names]
example_script_destinations = [joinpath(@__DIR__,"../scripts") for name in example_names]
example_documentation_destination = joinpath("src")
example_documentation_paths = [joinpath("$name.md") for name in example_names]



DocMeta.setdocmeta!(SynthAC, :DocTestSetup, :(using SynthAC); recursive=true)

for i in eachindex(example_names)
    Literate.markdown(example_literate_sources[i], example_documentation_destination; 
                      execute = false,
                      documenter = true)
    Literate.script(example_literate_sources[i], example_script_destinations[i])
end



makedocs(;
    sitename = "SynthAC.jl",
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
        "Examples" => "example.md",
    ],
    draft = false

    
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(;
    repo = "github.com/sandimas/SynthAC.jl",
    devbranch="main",

)
