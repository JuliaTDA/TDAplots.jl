module TDAplots

using Colors; using ColorSchemes;
using GLMakie; import NetworkLayout

export mean,
    @pipe,
    DataFrame,
    groupby;

include("plots.jl");
export rescale, 
    colorscale, 
    mapper_plot, 
    node_colors;

using MultivariateStats, ManifoldLearning;
include("layouts.jl");
export layout_generic,
    layout_mds,
    layout_hlle,
    layout_isomap,
    layout_lem,
    layout_lle,
    layout_ltsa,
    layout_tsne,
    layout_diffmap;

end
