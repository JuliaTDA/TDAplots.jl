module TDAplots

using Colors, ColorSchemes
using GLMakie
import NetworkLayout
using Reexport
@reexport using TDAmapper
using Graphs: edges
using Chain
using StatsBase: mean

export @chain

include("layout_naive.jl")
export NaiveLayouts

include("plots.jl")
export rescale,
    colorscale,
    metricspace_plot,
    mapper_plot,
    node_colors

using MultivariateStats, ManifoldLearning
import UMAP
import NetworkLayout
include("layouts.jl")
export layout_generic,
    centroid,
    layout_mds,
    layout_lle,
    layout_hlle,
    layout_lem,
    layout_ltsa,
    layout_diffmap,
    layout_tsne,
    layout_isomap,
    # MultivariateStats layouts
    layout_pca,
    layout_kpca,
    layout_ppca,
    layout_fa,
    layout_ica,
    # UMAP layout
    layout_umap,
    # Graph-topology layouts
    layout_spring,
    layout_stress,
    layout_spectral_graph,
    layout_sfdp,
    layout_shell

end
