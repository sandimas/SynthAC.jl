using Documenter
using SynthAC

makedocs(
    sitename = "SynthAC",
    format = Documenter.HTML(),
    modules = [SynthAC]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
