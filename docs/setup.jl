using Pkg

Pkg.activate(@__DIR__)
workspace = normpath(joinpath(@__DIR__, "..", ".."))
siblings = ["MetricSpaces.jl", "TDAmapper.jl", "TDAPersistenceDiagrams.jl", "ToMATo.jl"]
for name in siblings
    isdir(joinpath(workspace, name)) || error("Clone $name beside TDAplots.jl before running docs/setup.jl")
end
# Resolve renamed/unregistered dependencies in the same transaction.
specs = [PackageSpec(path=joinpath(workspace, name)) for name in siblings]
push!(specs, PackageSpec(path=normpath(joinpath(@__DIR__, ".."))))
Pkg.develop(specs)
Pkg.instantiate()
