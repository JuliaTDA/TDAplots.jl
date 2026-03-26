"""
    centroid(M::AbstractMapper)

Compute the centroid of each cover element, returning a `dim × n_clusters` matrix.

Each column is the mean of the points belonging to that cover element.
"""
function centroid(M::AbstractMapper)
    ctds = map(M.C) do ids
        pts = stack(M.X[ids])  # dim × n_points matrix
        vec(mean(pts, dims=2))
    end |> stack  # dim × n_clusters matrix

    return ctds
end

"""
    layout_generic(M::AbstractMapper, f::Function)

Apply a dimensionality reduction function `f` to the centroids of the mapper cover elements.

`f` should accept a `dim × n` matrix and return a `outdim × n` matrix.
Returns a vector of `Point{outdim}` suitable for plotting.
"""
function layout_generic(M::AbstractMapper, f::Function)
    ctd = centroid(M)
    result = f(ctd)
    dim = size(result, 1)
    @assert dim ∈ [2, 3] "Output dimension must be 2 or 3, got $dim"
    pos = [Point{dim}(result[:, i]) for i in axes(result, 2)]
    return pos
end

"""
    layout_mds(M::AbstractMapper; dim=2, kwargs...)

MDS (Multidimensional Scaling) layout of mapper nodes using cover element centroids.
"""
function layout_mds(M::AbstractMapper; dim::Integer=2, kwargs...)
    f = x -> predict(fit(MDS, x, distances=false, maxoutdim=dim, kwargs...))
    return layout_generic(M, f)
end

"""
    layout_lle(M::AbstractMapper; dim=2, kwargs...)

Locally Linear Embedding layout of mapper nodes.
"""
function layout_lle(M::AbstractMapper; dim::Integer=2, kwargs...)
    f = x -> predict(fit(LLE, x, maxoutdim=dim, kwargs...))
    return layout_generic(M, f)
end

"""
    layout_hlle(M::AbstractMapper; dim=2, kwargs...)

Hessian Locally Linear Embedding layout of mapper nodes.
"""
function layout_hlle(M::AbstractMapper; dim::Integer=2, kwargs...)
    f = x -> predict(fit(HLLE, x, maxoutdim=dim, kwargs...))
    return layout_generic(M, f)
end

"""
    layout_lem(M::AbstractMapper; dim=2, kwargs...)

Laplacian Eigenmaps layout of mapper nodes.
"""
function layout_lem(M::AbstractMapper; dim::Integer=2, kwargs...)
    f = x -> predict(fit(LEM, x, maxoutdim=dim, kwargs...))
    return layout_generic(M, f)
end

"""
    layout_ltsa(M::AbstractMapper; dim=2, kwargs...)

Local Tangent Space Alignment layout of mapper nodes.
"""
function layout_ltsa(M::AbstractMapper; dim::Integer=2, kwargs...)
    f = x -> predict(fit(LTSA, x, maxoutdim=dim, kwargs...))
    return layout_generic(M, f)
end

"""
    layout_diffmap(M::AbstractMapper; dim=2, kwargs...)

Diffusion Maps layout of mapper nodes.
"""
function layout_diffmap(M::AbstractMapper; dim::Integer=2, kwargs...)
    f = x -> predict(fit(DiffMap, x, maxoutdim=dim, kwargs...))
    return layout_generic(M, f)
end

"""
    layout_tsne(M::AbstractMapper; dim=2, kwargs...)

t-SNE layout of mapper nodes.
"""
function layout_tsne(M::AbstractMapper; dim::Integer=2, kwargs...)
    f = x -> predict(fit(TSNE, x, maxoutdim=dim, kwargs...))
    return layout_generic(M, f)
end

"""
    layout_isomap(M::AbstractMapper; dim=2, kwargs...)

Isomap layout of mapper nodes.
"""
function layout_isomap(M::AbstractMapper; dim::Integer=2, kwargs...)
    f = x -> predict(fit(Isomap, x, maxoutdim=dim, kwargs...))
    return layout_generic(M, f)
end
