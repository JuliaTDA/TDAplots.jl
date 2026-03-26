# TDAplots.jl

[![Build Status](https://github.com/JuliaTDA/TDAplots.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaTDA/TDAplots.jl/actions/workflows/CI.yml?query=branch%3Amain)

Visualization tools for Topological Data Analysis in Julia, built on [Makie](https://docs.makie.org/) and [TDAmapper.jl](https://github.com/JuliaTDA/TDAmapper.jl).

## Features

- **Mapper Graph Plotting**: Visualize mapper graphs in 2D and 3D with customizable node sizes, colors, and edge widths
- **Numeric and Categorical Coloring**: Color nodes by any numeric filter or by categorical labels (with automatic legend)
- **Graph Layouts**: Naive layouts (Spring, Spectral, Stress, etc.) via NetworkLayout.jl
- **Metric Layouts**: MDS, t-SNE, Isomap, LLE, Diffusion Maps, and more — positioning nodes based on the geometry of the underlying data
- **Full TDA Stack**: Re-exports TDAmapper.jl and MetricSpaces.jl, so `using TDAplots` gives you everything

## Installation

```julia
using Pkg
Pkg.add("TDAplots")
```

## Quick Start

```julia
using TDAplots
using TDAmapper.ImageCovers, TDAmapper.IntervalCovers, TDAmapper.Refiners

# Generate data and run mapper
X = sphere(1000, dim=2)
fv = first.(X)
ic = R1Cover(fv, Uniform(length=10, expansion=0.3))
M = classical_mapper(X, ic, DBscan(radius=0.1))

# Plot with default settings (Spring layout, nodes colored by first coordinate)
mapper_plot(M)
```

## Customization

```julia
# Custom node coloring (by any numeric vector)
heights = [p[2] for p in X]
mapper_plot(M, node_values=node_colors(M, heights))

# Categorical coloring (generates a legend)
labels = [x > 0 ? "right" : "left" for x in first.(X)]
mapper_plot(M, node_values=node_colors(M, labels))

# 3D layout
mapper_plot(M, layout_function=NetworkLayout.Spring(dim=3))
```

## Metric Layouts

Position mapper nodes using the geometry of the data, not just the graph structure:

```julia
using TDAplots

X = torus(2000)
fv = [p[3] for p in X]
ic = R1Cover(fv, Uniform(length=15, expansion=0.3))
M = classical_mapper(X, ic, DBscan(radius=0.3))

# MDS layout based on cover element centroids
pos = layout_mds(M)
mapper_plot(M, node_positions=pos)
```

Available metric layouts: `layout_mds`, `layout_lle`, `layout_hlle`, `layout_lem`, `layout_ltsa`, `layout_diffmap`, `layout_tsne`, `layout_isomap`.

## API Reference

| Function | Description |
| --- | --- |
| `mapper_plot(M; ...)` | Main plotting function for mapper graphs |
| `node_colors(M, v; f=mean)` | Aggregate values over cover elements |
| `colorscale(v)` | Map numeric vector to inferno colors |
| `rescale(x; min, max)` | Rescale a vector to a given range |
| `centroid(M)` | Compute centroids of cover elements |
| `layout_mds(M; dim=2)` | MDS layout |
| `layout_tsne(M; dim=2)` | t-SNE layout |
| `layout_isomap(M; dim=2)` | Isomap layout |

## See Also

- [MetricSpaces.jl](https://github.com/JuliaTDA/MetricSpaces.jl): Metric spaces, distances, and sampling
- [TDAmapper.jl](https://github.com/JuliaTDA/TDAmapper.jl): Mapper algorithms

## License

MIT License
