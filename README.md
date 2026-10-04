# TDAplots.jl

[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaTDA.github.io/TDAplots.jl/dev/)
[![Build Status](https://github.com/JuliaTDA/TDAplots.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaTDA/TDAplots.jl/actions/workflows/CI.yml?query=branch%3Amain)

Visualization for [JuliaTDA](https://github.com/JuliaTDA), built on Makie. Plot Mapper graphs, inspect which observations belong to a node, compare geometric and graph layouts, and draw persistence diagrams, barcodes and ToMATo results. `using TDAplots` re-exports TDAmapper and MetricSpaces; load a Makie backend separately.

## Installation

These ecosystem packages are currently unregistered. Resolve the required sources together, then add a backend compatible with Makie 0.23:

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

The `PersistenceDiagrams.jl` repository provides the renamed dependency `TDAPersistenceDiagrams`. Julia 1.9 or later is supported. Choose CairoMakie for static exports, GLMakie for an interactive desktop window, or WGLMakie for an interactive browser/notebook session. Their versions must satisfy the package's Makie compatibility.

## A circle, its Mapper, and the observations behind a node

```julia
using CairoMakie, TDAplots
using TDAmapper.ImageCovers: R1Cover
using TDAmapper.IntervalCovers: Uniform
using TDAmapper.Refiners: DBscan

θ = range(0, 2π; length=161)[1:end-1]
X = EuclideanSpace([[cos(t), sin(t)] for t in θ])
cover = R1Cover(first.(X), Uniform(length=8, expansion=0.35))
M = classical_mapper(X, cover, DBscan(radius=0.2))

fig = mapper_plot(M;
    node_positions=layout_landmarks(M),
    node_values=node_colors(M, [p[2] for p in X]),
    show_node_ids=true)
save("mapper-height.png", fig)

labels = [p[2] >= 0 ? "upper" : "lower" for p in X]
mapper_plot(M; node_positions=layout_landmarks(M),
    node_values=node_colors(M, labels))

explorer = mapper_explorer(M)
explorer.selected_node[] = 1
save("selected-node.png", explorer.figure)
```

Each node represents a subset `M.C[i]`, and an edge represents shared observations. Colours summarize values over that subset; default marker sizes rescale member counts. These are overlapping subsets, so summing node sizes does not count unique observations. A graph layout is a drawing of connectivity; distances in that drawing need not equal data distances.

The explorer supports numeric node values. Use GLMakie or WGLMakie for clicking and hover inspection; CairoMakie can export programmatically selected states. To use sample generators, import them explicitly: `using MetricSpaces.Datasets: sphere, torus`.

## Choose the view for the question

| Question | Functions |
| :--- | :--- |
| Where are the observations? | `metricspace_plot` |
| How do Mapper subsets overlap? | `mapper_plot`, `mapper_explorer` |
| Does the drawing reflect connectivity or geometry? | `layout_spring`, `layout_landmarks`, `layout_mds`, `layout_pca`, manifold layouts |
| At what scales do homology features live? | `persistence_plot`, `barcode_plot` |
| Which density modes might be merged? | `tomato_graph_plot`, `tomato_persistence_plot` |

The [documentation](https://JuliaTDA.github.io/TDAplots.jl/dev/) contains executable tutorials, a layout guide, persistence and ToMATo interpretation, export recipes and troubleshooting. The [API page](https://JuliaTDA.github.io/TDAplots.jl/dev/api/) documents all plotting functions.

## Build the documentation

Clone MetricSpaces.jl, TDAmapper.jl, ToMATo.jl and TDAPersistenceDiagrams.jl beside this repository. The last directory can be cloned from `https://github.com/JuliaTDA/PersistenceDiagrams.jl` using `TDAPersistenceDiagrams.jl` as its destination name.

```bash
julia --project=docs docs/setup.jl
julia --project=docs docs/make.jl
```

Open `docs/build/index.html`. The default build is local; `JULIATDA_DOCS_DEPLOY=true` explicitly enables the deployment step. In a configured development environment, run package tests with `julia --project=. -e 'using Pkg; Pkg.test()'`.

MIT license.
