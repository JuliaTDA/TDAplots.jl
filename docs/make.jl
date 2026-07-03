using Documenter
using TDAplots

DocMeta.setdocmeta!(TDAplots, :DocTestSetup, :(using TDAplots); recursive = true)

makedocs(;
    modules = [TDAplots],
    sitename = "TDAplots.jl",
    authors = "G. Vituri and contributors",
    # `using TDAplots` re-exports TDAmapper/MetricSpaces, and several docstrings
    # cross-reference symbols documented in those packages' own sites. Skip
    # doctesting, do not require every re-exported symbol to appear here, and
    # demote unresolved cross-references to warnings so the site still renders.
    doctest = false,
    checkdocs = :none,
    warnonly = [:cross_references, :docs_block],
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://JuliaTDA.github.io/TDAplots.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "API reference" => "api.md",
    ],
)

deploydocs(;
    repo = "github.com/JuliaTDA/TDAplots.jl",
    devbranch = "main",
)
