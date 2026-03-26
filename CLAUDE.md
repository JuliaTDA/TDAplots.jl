# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TDAplots.jl provides visualization for TDA Mapper results using GLMakie. It sits at the top of the TDA stack: `using TDAplots` re-exports both TDAmapper.jl and MetricSpaces.jl, giving users the full pipeline from point clouds to plots.

## Common Commands

```bash
# Run all tests
julia --project=. -e 'using Pkg; Pkg.test()'

# Load package in REPL for development
julia --project=. -e 'using Revise; using TDAplots'
```

## Architecture

Three source files under `src/`:

**`plots.jl`** - Core visualization:
- `mapper_plot(M; layout, node_color, ...)` - Main plotting function, renders mapper graph with GLMakie
- `node_colors(M, values; f=mean)` - Aggregate per-point values to per-node colors. Supports numeric (applies colorscale) and categorical (returns labels for legend)
- `rescale(x; min, max)` - Min-max normalization, also works curried: `rescale(min=a, max=b)`
- `colorscale(v)` - Maps numeric vector to `:inferno` color scheme

**`layouts.jl`** - Graph layout algorithms, all take a `Mapper` and return 2D/3D coordinates:
- **Graph-topology**: `layout_spring`, `layout_stress`, `layout_spectral_graph`, `layout_sfdp`, `layout_shell` (via NetworkLayout.jl)
- **Metric/geometric**: `layout_mds`, `layout_isomap`, `layout_tsne`, `layout_umap` (via MultivariateStats/ManifoldLearning/UMAP)
- **Manifold learning**: `layout_lle`, `layout_hlle`, `layout_lem`, `layout_ltsa`, `layout_diffmap`
- **Statistical**: `layout_pca`, `layout_kpca`, `layout_ppca`, `layout_fa`, `layout_ica`
- `layout_generic(M, f)` - Apply any layout function `f` to the mapper
- `centroid(M)` - Compute centroids of cover elements in the original space

**`layout_naive.jl`** - `NaiveLayouts` submodule that re-exports NetworkLayout.jl algorithms directly.

**Key design patterns:**
- All layout functions follow the signature `layout_*(M::AbstractMapper; dim=2, kwargs...)` returning a vector of coordinate tuples
- Metric-aware layouts compute pairwise distances between node centroids, then embed
- `@reexport using TDAmapper` — full TDA stack available with a single import
- Tests cover utility functions and integration with actual mapper objects

## Dependencies

- **TDAmapper.jl** - Mapper algorithms (re-exported, which also re-exports MetricSpaces.jl)
- **GLMakie.jl** - GPU-accelerated plotting backend
- **NetworkLayout.jl** - Graph layout algorithms (Spring, Stress, SFDP, etc.)
- **ManifoldLearning.jl** - LLE, Isomap, Laplacian Eigenmaps, Diffusion Maps
- **MultivariateStats.jl** - PCA, MDS, Factor Analysis, ICA
- **UMAP.jl** - UMAP dimensionality reduction
- **ColorSchemes.jl** / **Colors.jl** - Color mapping for node visualization
