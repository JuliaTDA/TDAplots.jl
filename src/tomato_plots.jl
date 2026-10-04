"""
    tomato_graph_plot(X::EuclideanSpace, g, values)

Given a nonempty Euclidean space `X` with at least 2 coordinates, a graph `g`
whose vertices match point IDs, and a numeric vector `values` (one per point),
plot graph edges and observations colored by `values`. Inputs with more than
3 coordinates use their first 3 coordinates without fitting an embedding.

The plot uses a continuous colorbar. For a categorical cluster legend, use
[`metricspace_plot`](@ref) with `color=string.(labels)` instead. Returns a Makie
`Figure`.
"""
function tomato_graph_plot(X::EuclideanSpace, g, values)
    M = as_matrix(X)
    n_dim = clamp(size(M, 1), 2, 3)
    n_pts = length(X)

    node_positions = [Point{n_dim}(M[1:n_dim, i]) for i in 1:n_pts]

    fig = Figure()
    ax = n_dim == 2 ? Axis(fig[1, 1]) : Axis3(fig[1, 1])

    scatter!(ax, node_positions, color=values)
    Colorbar(fig[1, 2], colorrange=extrema(values))

    for e in edges(g)
        e.src == e.dst && continue
        linesegments!(
            ax, [node_positions[e.src], node_positions[e.dst]],
            color=:black, linewidth=0.5, alpha=0.5
        )
    end

    fig
end

"""
    tomato_persistence_plot(births_and_deaths; max_value_multiplier=1.3)

Plot the nonempty ToMATo dictionary `peak_point_id => [birth_density, death_density]`
as `(birth_density, birth_density - death_density)`. To inspect recorded finite
mode prominences before selecting a threshold, use a ToMATo run with `τ=Inf`;
that run allows merging without a finite prominence cutoff.

`death_density=Inf` denotes an unmerged mode. Its resulting `-Inf` ordinate is
displayed at `max_value_multiplier` times the largest finite prominence, or
times the largest birth if no finite prominences exist. This is a display
surrogate, not a measured finite lifetime; the helper does not specially mark
these points. Returns a Makie `FigureAxisPlot`, whose `.axis` can be labelled.
"""
function tomato_persistence_plot(births_and_deaths; max_value_multiplier=1.3)
    bds = [[x[2][1], x[2][1] - x[2][2]] for x in births_and_deaths] |> stack
    finite_vals = filter(!isinf, bds[2, :])
    max_value = isempty(finite_vals) ? maximum(bds[1, :]) : maximum(finite_vals)
    replace!(bds, -Inf => max_value * max_value_multiplier)
    scatter(bds)
end
