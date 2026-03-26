module TDAplots

using Colors, ColorSchemes
using GLMakie
import NetworkLayout
using Reexport
@reexport using TDAmapper
using Chain
using StatsBase: mean

export @chain

include("layout_naive.jl")
export NaiveLayouts

include("plots.jl")
export rescale,
    colorscale,
    mapper_plot,
    node_colors

using MultivariateStats, ManifoldLearning
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
    layout_isomap

end
