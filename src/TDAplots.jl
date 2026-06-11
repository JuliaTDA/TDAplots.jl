module TDAplots

using Colors, ColorSchemes
using Makie
import NetworkLayout
using Reexport
@reexport using TDAmapper
using PersistenceDiagrams
using Graphs: edges, ne
using Chain
using StatsBase: mean
using MetricSpaces: EuclideanSpace, as_matrix

export @chain

include("layout_naive.jl")
export NaiveLayouts

include("plots.jl")
export rescale,
    colorscale,
    metricspace_plot,
    mapper_plot,
    node_colors

include("explorer.jl")
export mapper_explorer,
    MapperExplorer

include("persistence_plots.jl")
export persistence_plot,
    barcode_plot

include("tomato_plots.jl")
export tomato_graph_plot,
    tomato_persistence_plot

using MultivariateStats, ManifoldLearning
import UMAP
import NetworkLayout
include("layouts.jl")
export layout_generic,
    centroid,
    layout_landmarks,
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
