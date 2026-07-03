# TDAplots.jl

*Visualization for Topological Data Analysis in Julia, built on [Makie](https://docs.makie.org/) and [TDAmapper.jl](https://github.com/JuliaTDA/TDAmapper.jl).*

```@meta
CurrentModule = TDAplots
```

`TDAplots.jl` sits at the top of the [JuliaTDA](https://github.com/JuliaTDA)
Mapper stack: `using TDAplots` re-exports both `TDAmapper` and `MetricSpaces`,
so a single import gives you the whole pipeline from point clouds to plots. It
renders Mapper graphs, persistence diagrams and barcodes, and provides an
interactive [`mapper_explorer`](@ref) for linked selection between a Mapper
graph and the underlying data.

You must load a Makie backend (`CairoMakie`, `GLMakie`, or `WGLMakie`) before
plotting — `CairoMakie` for static figures, `GLMakie`/`WGLMakie` for interactive
windows.

## Features

* **Mapper graph plotting** — [`mapper_plot`](@ref) renders a Mapper graph in 2D
  or 3D with customizable node size, colour and edge width.
* **Numeric & categorical colouring** — [`node_colors`](@ref) aggregates a
  per-point filter to per-node colours, handling both numeric scales and
  categorical labels (with an automatic legend).
* **Many layouts** — graph-topology layouts (`layout_spring`, `layout_stress`,
  `layout_sfdp`, …) and metric/manifold layouts (`layout_mds`, `layout_isomap`,
  `layout_tsne`, `layout_umap`, `layout_diffmap`, …) that position nodes by the
  geometry of the underlying data.
* **Persistence visuals** — [`persistence_plot`](@ref) and [`barcode_plot`](@ref).
* **Interactive exploration** — [`mapper_explorer`](@ref) links a Mapper graph to
  a scatter of the data: clicking a node highlights its members.

## Installation

`TDAplots.jl` builds on the unregistered ecosystem packages
[MetricSpaces.jl](https://github.com/JuliaTDA/MetricSpaces.jl) and
[TDAmapper.jl](https://github.com/JuliaTDA/TDAmapper.jl). Until everything is
registered in the General registry, `develop` the siblings from their URLs:

```julia
using Pkg
Pkg.develop(url = "https://github.com/JuliaTDA/MetricSpaces.jl")
Pkg.develop(url = "https://github.com/JuliaTDA/TDAmapper.jl")
Pkg.develop(url = "https://github.com/JuliaTDA/TDAplots.jl")
```

## Quick start

```julia
using CairoMakie          # or GLMakie / WGLMakie
using TDAplots
using TDAmapper.ImageCovers, TDAmapper.IntervalCovers, TDAmapper.Refiners

# Generate data on a circle and run Mapper
X  = sphere(1000, dim = 2)
fv = first.(X)
ic = R1Cover(fv, Uniform(length = 10, expansion = 0.3))
M  = classical_mapper(X, ic, DBscan(radius = 0.1))

# Plot (default: spring layout, nodes coloured by the first coordinate)
mapper_plot(M)

# Colour nodes by any numeric filter…
heights = [p[2] for p in X]
mapper_plot(M; node_values = node_colors(M, heights))

# …or by a categorical label (draws a legend)
labels = [x > 0 ? "right" : "left" for x in first.(X)]
mapper_plot(M; node_values = node_colors(M, labels))
```

## Metric layouts

Position Mapper nodes using the geometry of the data rather than only the graph
structure:

```julia
X  = torus(2000)
fv = [p[3] for p in X]
ic = R1Cover(fv, Uniform(length = 15, expansion = 0.3))
M  = classical_mapper(X, ic, DBscan(radius = 0.3))

pos = layout_mds(M)               # MDS on cover-element centroids
mapper_plot(M; node_positions = pos)
```

Available metric/manifold layouts include `layout_mds`, `layout_isomap`,
`layout_tsne`, `layout_umap`, `layout_lle`, `layout_hlle`, `layout_lem`,
`layout_ltsa`, and `layout_diffmap`.

## Interactive exploration

```julia
using GLMakie             # interactive backend
using TDAplots

res = mapper_explorer(M)          # returns a MapperExplorer
res.selected_node[] = 3           # programmatically select node 3
```

`mapper_explorer` returns a [`MapperExplorer`](@ref) whose `selected_node`
`Observable` drives a linked highlight in a scatter of the underlying data.

## See also

* [MetricSpaces.jl](https://github.com/JuliaTDA/MetricSpaces.jl) — metric spaces,
  distances and sampling.
* [TDAmapper.jl](https://github.com/JuliaTDA/TDAmapper.jl) — Mapper algorithms.
* [JuliaTDA.jl](https://github.com/JuliaTDA/JuliaTDA.jl) — the umbrella package.
