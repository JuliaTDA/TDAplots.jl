"""
    tomato_graph_plot(X::EuclideanSpace, g, values)

Given a metric space `X` in 2 or 3 dimensions, a graph `g` obtained with
`proximity_graph` and a numeric vector `values` (one per point),
plot the proximity graph with nodes colored by `values`.
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

Plot the persistence diagram from ToMATo output. Useful to decide the best
value of τ before applying the ToMATo algorithm again.
"""
function tomato_persistence_plot(births_and_deaths; max_value_multiplier=1.3)
    bds = [[x[2][1], x[2][1] - x[2][2]] for x in births_and_deaths] |> stack
    finite_vals = filter(!isinf, bds[2, :])
    max_value = isempty(finite_vals) ? maximum(bds[1, :]) : maximum(finite_vals)
    replace!(bds, -Inf => max_value * max_value_multiplier)
    scatter(bds)
end
