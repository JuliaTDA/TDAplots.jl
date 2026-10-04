# TDAplots.jl

A useful topology picture should let you ask where its shapes came from. `TDAplots.jl` turns a Mapper graph into a view of overlapping subsets, links nodes back to their observations, and supplies persistence and density-mode plots for the rest of the JuliaTDA workflow.

`using TDAplots` re-exports TDAmapper and MetricSpaces. Plotting still requires a separately loaded Makie backend. ToMATo and TDAPersistenceDiagrams examples import their own APIs explicitly.

| Start here | What you will learn |
| :--- | :--- |
| [Mapper tutorial](mapper.md) | Build a circle example, colour nodes, select members and export figures |
| [Layouts and interpretation](layouts.md) | Distinguish graph topology from centroid geometry and use custom layouts |
| [Persistence and ToMATo](persistence.md) | Read diagrams, barcodes and mode prominences without mixing conventions |
| [Practical guide](practical.md) | Inputs, backends, exports, common errors and performance |
| [API reference](api.md) | Plotting, layout and utility signatures |

## Installation

Use Julia 1.9 or later. The packages are currently unregistered, so resolve all required sources in one operation:

```julia
using Pkg
Pkg.activate("tda-plots-example"; shared=false)
Pkg.develop([
    PackageSpec(url="https://github.com/JuliaTDA/MetricSpaces.jl"),
    PackageSpec(url="https://github.com/JuliaTDA/TDAmapper.jl"),
    PackageSpec(url="https://github.com/JuliaTDA/PersistenceDiagrams.jl"),
    PackageSpec(url="https://github.com/JuliaTDA/TDAplots.jl"),
])
Pkg.add(PackageSpec(name="CairoMakie", version="0.14"))
```

The `PersistenceDiagrams.jl` repository provides the renamed module `TDAPersistenceDiagrams`. For the optional ToMATo tutorial, include `PackageSpec(url="https://github.com/JuliaTDA/ToMATo.jl")` in the same development list or develop it afterward, once MetricSpaces is resolved. For sibling checkouts, replace URLs with local `path` entries relative to your working directory.

## Select a backend

| Backend | Use it for | Requirement |
| :--- | :--- | :--- |
| CairoMakie | Static PNG, SVG or PDF figures and headless docs builds | Install compatible CairoMakie; no interactive clicking |
| GLMakie | Interactive desktop exploration and hover inspection | A working graphics/display environment |
| WGLMakie | Interactive browser or notebook exploration | A frontend capable of hosting its interactive output |

The package currently requires Makie 0.23; CairoMakie 0.14 is the backend version used by its tests and docs. Consult the chosen backend's compatibility when installing other backends. Load one with `using CairoMakie` (or the chosen backend) before constructing figures. See the [Makie documentation](https://docs.makie.org/) for backend configuration.

## Build the docs

Place MetricSpaces.jl, TDAmapper.jl, ToMATo.jl and TDAPersistenceDiagrams.jl beside this repository. The persistence dependency's source URL is `https://github.com/JuliaTDA/PersistenceDiagrams.jl`; clone it into the directory `TDAPersistenceDiagrams.jl`.

```bash
julia --project=docs docs/setup.jl
julia --project=docs docs/make.jl
```

The setup instantiates a dedicated environment including CairoMakie. The build runs the `@example` tutorials and writes `docs/build/index.html`. It does not publish unless `JULIATDA_DOCS_DEPLOY=true` is explicitly set. The interactive mouse behavior is described in the guide; the headless examples exercise programmatic selection.

## Related packages

[MetricSpaces.jl](https://github.com/JuliaTDA/MetricSpaces.jl) supplies geometry; [TDAmapper.jl](https://github.com/JuliaTDA/TDAmapper.jl) constructs Mapper; [ToMATo.jl](https://github.com/JuliaTDA/ToMATo.jl) supplies density clustering; [JuliaTDA.jl](https://github.com/JuliaTDA/JuliaTDA.jl) provides the umbrella API.
