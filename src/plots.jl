"""
    metricspace_plot(X::EuclideanSpace; dims=nothing, color=nothing, markersize=10)

Plot a `EuclideanSpace` as a scatter plot using Makie.

# Keyword Arguments
- `dims`: which dimensions to plot (e.g., `[1, 3, 5]`). Defaults to the first 2 or 3 dimensions.
  If the data is 2D, plots 2D; if 3D+, plots the first 3 dimensions.
- `color`: a `Vector{<:Number}` (mapped to a colorscale with colorbar) or a
  `Vector{<:AbstractString}` (categorical, with legend). If `nothing`, uses a default color.
- `markersize`: marker size for the scatter plot (default: 10).
"""
function metricspace_plot(
    X::EuclideanSpace;
    dims=nothing,
    color=nothing,
    markersize=10
)
    N = length(X[1])

    if isnothing(dims)
        dims = collect(1:min(N, 3))
    end

    ndims = length(dims)
    if ndims < 2 || ndims > 3
        error("dims must specify 2 or 3 dimensions, got $ndims")
    end

    if ndims == 2
        positions = [Point2f(x[dims[1]], x[dims[2]]) for x in X]
    else
        positions = [Point3f(x[dims[1]], x[dims[2]], x[dims[3]]) for x in X]
    end

    f = Figure()
    ax = ndims == 2 ? Axis(f[1, 1]) : Axis3(f[1, 1])

    if isnothing(color)
        scatter!(ax, positions, markersize=markersize)
    elseif color isa Vector{<:Number}
        scatter!(ax, positions, markersize=markersize, color=color)
        Colorbar(f[1, 2], colorrange=extrema(color))
    elseif color isa Vector{<:AbstractString}
        groups = Dict{String,Vector{Int}}()
        for (i, label) in enumerate(color)
            ids = get!(groups, label, Int[])
            push!(ids, i)
        end
        for label in sort(collect(keys(groups)))
            idx = groups[label]
            scatter!(ax, positions[idx], markersize=markersize, label=label)
        end
        Legend(f[1, 2], ax, merge=true)
    end

    hidedecorations!(ax)
    hidespines!(ax)

    return f
end

"""
    colorscale(v)

Map a numeric vector `v` to a color vector using the `:inferno` color scheme.

Values are min-max normalized to [0, 1] before mapping.
"""
function colorscale(v)
    min_val = minimum(v)
    max_val = maximum(v)
    range_val = max_val - min_val

    if range_val ≈ 0
        range_val = 1
    end

    color_vec = get.(Ref(cgrad(:inferno)), (v .- min_val) ./ range_val)
    return color_vec
end

"""
    rescale(x; min=0, max=1)

Rescale a numeric vector `x` to lie within [`min`, `max`].
"""
function rescale(x; min=0, max=1)
    dif = max - min
    x_min = minimum(x)
    x_max = maximum(x)
    x_range = x_max - x_min

    if x_range ≈ 0
        return fill(mean([min, max]), length(x))
    end

    return (x .- x_min) ./ x_range .* dif .+ min
end

"""
    rescale(; min=0, max=1)

Return a curried version of `rescale`.
"""
function rescale(; min=0, max=1)
    x -> rescale(x; min=min, max=max)
end

"""
    node_colors(M::AbstractMapper, v::Vector{<:Number}; f::Function=mean)

Compute a summary value for each node (cover element) in the mapper graph.

For each cover element, applies `f` to the subset of `v` indexed by that element.
If `v` is not provided, defaults to the first coordinate of each point.
"""
function node_colors(M::AbstractMapper, v::Union{Nothing,Vector{<:Number}}=nothing; f::Function=mean)
    if isnothing(v)
        v = first.(M.X)
    end

    return map(M.C) do ids
        f(v[ids])
    end
end

"""
    node_colors(M::AbstractMapper, v::Vector{<:AbstractString}; f::Function=_mode_string)

Compute a categorical label for each node by finding the most common string in each cover element.
"""
function node_colors(M::AbstractMapper, v::Vector{<:AbstractString}; f::Function=_mode_string)
    return map(M.C) do ids
        f(v[ids])
    end
end

"""
Find the most common string in a collection. In case of ties, join up to `max_ties` values with "/".
"""
function _mode_string(s; max_ties=3)
    counts = Dict{eltype(s),Int}()
    for x in s
        counts[x] = get(counts, x, 0) + 1
    end
    n_max = maximum(values(counts))
    winners = sort([k for (k, v) in counts if v == n_max])
    return join(winners[1:min(length(winners), max_ties)], "/")
end

"""
    mapper_plot(M::AbstractMapper; kwargs...)

Plot a mapper graph using Makie.

# Keyword Arguments
- `node_positions`: positions for each node (default: Spring layout)
- `node_size`: sizes for each node (default: proportional to cover element size)
- `node_values`: values for coloring nodes (default: mean of first coordinate per cover element).
  Can be a `Vector{<:Number}` (colorscale) or `Vector{<:AbstractString}` (legend).
- `edge_size`: line width for edges (default: 1)
- `layout_function`: a NetworkLayout algorithm (default: `NetworkLayout.Spring(dim=2)`)
"""
function mapper_plot(
    M::AbstractMapper;
    node_positions=nothing,
    node_size=nothing,
    node_values=nothing,
    edge_size=1,
    layout_function=NetworkLayout.Spring(dim=2)
)
    g = M.g
    C = M.C

    if isnothing(node_positions)
        node_positions = layout_function(g)
    end

    dim = length(node_positions[1])

    if isnothing(node_size)
        node_size = @chain begin
            map(length, C)
            rescale(min=10, max=75)
        end
    end

    if isnothing(node_values)
        node_values = node_colors(M)
    end

    # Create figure
    f = Figure()
    if dim == 2
        ax = Axis(f[1, 1])
    else
        ax = Axis3(f[1, 1])
    end

    # Plot edges
    for e in edges(g)
        e.src >= e.dst && continue
        linesegments!(ax, [node_positions[e.src], node_positions[e.dst]], color=:black, linewidth=edge_size)
    end

    # Plot nodes
    if node_values isa Vector{<:AbstractString}
        # Categorical: group by class and add legend
        groups = Dict{String,Vector{Int}}()
        for (i, label) in enumerate(node_values)
            ids = get!(groups, label, Int[])
            push!(ids, i)
        end

        for label in sort(collect(keys(groups)))
            idx = groups[label]
            scatter!(ax, node_positions[idx], markersize=node_size[idx], label=label)
        end
        Legend(f[1, 2], ax, merge=true)
    else
        # Numeric: use colorscale
        scatter!(ax, node_positions, markersize=node_size, color=node_values)
        Colorbar(f[1, 2], colorrange=extrema(node_values))
    end

    hidedecorations!(ax)
    hidespines!(ax)

    return f
end
