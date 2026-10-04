# Inputs, exports and troubleshooting

```@meta
CurrentModule = TDAplots
```

## Input contracts

The plotting routines assume aligned, nonempty inputs; they do not validate every mismatch. Prepare the numerical result before drawing it.

| Function/input | Required alignment |
| :--- | :--- |
| `metricspace_plot(X; color, dims)` | Nonempty `EuclideanSpace`, two/three selected coordinates, one colour value per observation |
| `node_colors(M, values)` | One number or string per original observation in `M.X` |
| `mapper_plot` node vectors | One position, size or summary value per node in `M.C`/`M.g` |
| `mapper_explorer(...; data)` | One two/three-dimensional embedded point per observation, in original order |
| `tomato_graph_plot(X, g, values)` | Graph vertices and numeric values match original point IDs; at least two coordinates |
| Persistence plotting | One `PersistenceDiagram` or a vector of that type; homology dimension is metadata |

Colours support `Vector{<:Number}` or `Vector{<:AbstractString}` in the cloud and Mapper plotters. Convert categorical integers or symbols with `string.(labels)`. The explorer supports numeric values only. `colorscale` returns colour objects for low-level plotting; `mapper_plot(node_values=...)` expects numeric summaries or strings, rather than those objects.

## Sizes, scales and custom summaries

`rescale(v; min=0, max=1)` maps a nonempty numeric vector by its minimum and maximum. Constant vectors map to the midpoint of the requested range. `rescale(; min, max)` returns a function you can compose into a pipeline. `colorscale(v)` independently maps numeric values to inferno colours; it uses the bottom of that scale for a constant input.

Mapper defaults are mean first coordinate for numeric node values, a spring graph layout for positions, and member counts rescaled to marker sizes 10–75. `colormap=:viridis` controls numeric Mapper and cloud colours, while categorical colours use the backend's categorical cycle.

A numeric colour range is computed separately for each figure. If comparisons require identical fixed limits, build a custom Makie figure with a shared `colorrange`; the high-level Mapper helper currently has no `colorrange` keyword. Similarly, its colourbar reports numeric summaries, not a label for the measurement unit; annotate exports or construct a custom figure when that context matters.

## Save and display

```julia
using CairoMakie, TDAplots
# Continue from a tutorial with M already constructed.
fig = mapper_plot(M)
save("mapper.png", fig; px_per_unit=2)
save("mapper.svg", fig)
save("mapper.pdf", fig)
```

Set figure size and style through a Makie theme before construction, or edit the returned figure. `mapper_plot`, `metricspace_plot`, `persistence_plot`, `barcode_plot` and `tomato_graph_plot` return `Figure`s. `mapper_explorer` returns a wrapper; save `result.figure`. `tomato_persistence_plot` returns a `FigureAxisPlot`; save it or use its `.figure` and `.axis` for presentation adjustments.

In scripts, explicitly `display(fig)` when using an interactive backend, or save an image when using CairoMakie. Notebook rendering depends on the frontend and active backend. For GUI exploration install a compatible interactive backend in the same project rather than switching packages across unrelated environments.

## Troubleshooting

| Symptom | Likely cause and action |
| :--- | :--- |
| Package resolution fails | Develop unregistered siblings simultaneously, including TDAPersistenceDiagrams from the PersistenceDiagrams.jl URL |
| `sphere` or `torus` is undefined | Import `MetricSpaces.Datasets: sphere, torus`; dataset helpers are not top-level re-exports |
| Backend/display error | Install and load a compatible Makie backend; use CairoMakie for a headless machine |
| Explorer renders but clicks do nothing | Static backend/output; use GLMakie or a supported WGLMakie frontend |
| Explorer rejects string values | It supports numeric values only; use `mapper_plot` for categorical colouring |
| Unknown `layout` or `node_positions` keyword | Mapper uses `node_positions`/`layout_function`; explorer uses only `layout_function` |
| Layout receives a graph instead of Mapper | `layout_function` is called on `M.g`; capture `M` in a closure for package wrappers |
| Bounds/dimension errors | Check vector lengths and matrix orientation; require two/three output coordinates |
| Empty Mapper cannot be plotted | Check cover/refiner parameters before plotting; node geometry requires at least one node |
| Embedding fails on few nodes | Reduce neighbour count or dimension, or start with `layout_landmarks`/a graph layout |
| Infinite intervals seem finite | Plot endpoints use display surrogates; inspect interval data and set `infinity` explicitly |

## Performance and interpretation

Mapper graph edges are batched into one plotting call. Node colour aggregation visits member sets; heavy overlap increases work. Layout fitting can dominate plot construction, especially dense manifold methods on many centroids. Compute positions once and reuse them for a fair comparison of colour summaries.

The explorer redraws observation colours when selection changes, so very large point clouds can make interaction slower. Use a display embedding with the same number/order of points, or build a smaller Mapper for exploration. Do not silently subsample the right-panel data while retaining full membership indices.

`tomato_graph_plot` currently makes a plotting call per edge; dense graphs can therefore be slow to render. Inspect a smaller representative dataset or write a batched custom Makie view for large graphs. Plotting makes a result visible; it does not validate the chosen cover, filtration, density estimator or cluster threshold.
