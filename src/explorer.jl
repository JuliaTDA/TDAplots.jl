# Interactive mapper exploration.
#
# Provides `mapper_explorer`, a two-panel linked view: the mapper graph on the
# left and the original data points on the right. Selecting a node (by click, or
# programmatically through the returned observable) highlights that node's member
# points in the right panel and marks the node in the graph. Everything is driven
# off a single `Observable`, so the interaction can be tested without a mouse.

"""
    MapperExplorer

Return value of [`mapper_explorer`](@ref). Wraps the interactive `Figure` together
with the `selected_node` observable.

# Fields
- `figure::Figure`: the two-panel figure (mapper graph + data scatter).
- `selected_node::Observable{Union{Nothing,Int}}`: the currently selected node id
  (`nothing` when no node is selected).

Displaying a `MapperExplorer` displays its `figure`, so you can return it from a
REPL/notebook cell directly. You may also access `result.figure` explicitly.
"""
struct MapperExplorer
    figure::Figure
    selected_node::Observable{Union{Nothing,Int}}
end

# Forward display/show to the underlying figure so returning a MapperExplorer from
# a REPL or notebook cell renders the plot as expected.
Base.display(me::MapperExplorer) = display(me.figure)
Base.show(io::IO, me::MapperExplorer) =
    print(io, "MapperExplorer(figure, selected_node = $(me.selected_node[]))")
Base.show(io::IO, ::MIME"text/plain", me::MapperExplorer) = show(io, me)

# Destructuring helpers so callers can write `(; figure, selected_node) = res`
# or `res.figure` / `res.selected_node`.
Base.getproperty(me::MapperExplorer, s::Symbol) = getfield(me, s)
Base.propertynames(::MapperExplorer) = (:figure, :selected_node)

"""
    _node_geometry(M; node_positions, node_size, node_values, layout_function)

Compute the shared node geometry used by both `mapper_plot` and `mapper_explorer`:
node positions (via `layout_function` unless given), node sizes (∝ cover-element
size, rescaled, unless given) and node values (via [`node_colors`](@ref) unless
given). Returns `(node_positions, node_size, node_values, dim)`.
"""
function _node_geometry(
    M::AbstractMapper;
    node_positions=nothing,
    node_size=nothing,
    node_values=nothing,
    layout_function=NetworkLayout.Spring(dim=2)
)
    if isnothing(node_positions)
        node_positions = layout_function(M.g)
    end

    dim = length(node_positions[1])

    if isnothing(node_size)
        node_size = @chain begin
            map(length, M.C)
            rescale(min=10, max=75)
        end
    end

    if isnothing(node_values)
        node_values = node_colors(M)
    end

    return node_positions, node_size, node_values, dim
end

"""
    _data_positions(M; data, dims)

Compute the right-panel data positions. If `data` is given (a vector of points or
tuples with 2 or 3 coordinates) it is used directly; otherwise the first 2–3
coordinates of `M.X` are taken, honoring `dims` like `metricspace_plot`.

Returns `(positions, ndims)`.
"""
function _data_positions(M::AbstractMapper; data=nothing, dims=nothing)
    if !isnothing(data)
        ndims = length(first(data))
        (ndims == 2 || ndims == 3) ||
            error("data points must have 2 or 3 coordinates, got $ndims")
        positions = ndims == 2 ?
            [Point2f(p[1], p[2]) for p in data] :
            [Point3f(p[1], p[2], p[3]) for p in data]
        return positions, ndims
    end

    X = M.X
    N = length(X[1])
    if isnothing(dims)
        dims = collect(1:min(N, 3))
    end
    ndims = length(dims)
    if ndims < 2 || ndims > 3
        error("dims must specify 2 or 3 dimensions, got $ndims")
    end
    positions = ndims == 2 ?
        [Point2f(x[dims[1]], x[dims[2]]) for x in X] :
        [Point3f(x[dims[1]], x[dims[2]], x[dims[3]]) for x in X]
    return positions, ndims
end

"""
    mapper_explorer(M::AbstractMapper; data=nothing, node_values=nothing,
        node_size=nothing, colormap=:viridis, edge_size=1,
        layout_function=NetworkLayout.Spring(dim=2), markersize=6,
        dims=nothing, inspector=false)

Build an interactive two-panel exploration figure for a mapper result.

The **left** panel renders the mapper graph using the same rules as
[`mapper_plot`](@ref) (nodes sized ∝ cover-element size, colored by `node_values`).
The **right** panel scatters the original data points. Selecting a node — by
clicking it, or by setting the returned observable — highlights that node's member
points on the right (full opacity) while dimming the rest, and outlines the
selected node on the left.

# Return value
A [`MapperExplorer`](@ref) which behaves like the NamedTuple
`(figure, selected_node)`:
- `result.figure::Figure` — the figure (also displayed automatically if you return
  `result` from a REPL/notebook cell).
- `result.selected_node::Observable{Union{Nothing,Int}}` — the selected node id, or
  `nothing`. Set it (`result.selected_node[] = i`) to drive the highlight
  programmatically; this is what tests exercise.

# Keyword Arguments
- `data`: a vector of points/tuples with 2 or 3 coordinates for the right panel.
  Defaults to the first 2–3 coordinates of `M.X` (honoring `dims`).
- `node_values`: numeric values for coloring nodes (default: [`node_colors`](@ref)).
  Only numeric `node_values` are supported here (categorical coloring is not — use
  [`mapper_plot`](@ref) for that).
- `node_size`: sizes for each node (default: ∝ cover-element size, rescaled).
- `colormap`: Makie colormap for `node_values` (default: `:viridis`).
- `edge_size`: line width for graph edges (default: 1).
- `layout_function`: a NetworkLayout algorithm for node positions
  (default: `NetworkLayout.Spring(dim=2)`).
- `markersize`: marker size for the right-panel data points (default: 6).
- `dims`: which dimensions of `M.X` to plot when `data` is not given (e.g.
  `[1, 3]`). Defaults to the first 2 or 3 dimensions.
- `inspector`: if `true`, instantiate a `DataInspector` so hovering a node shows a
  tooltip (default: `false`). Hover tooltips require an interactive backend
  (e.g. GLMakie/WGLMakie); on non-interactive backends this is a no-op. The node
  scatter always carries an `inspector_label`, so enabling a `DataInspector`
  yourself works too.

# Example
```julia
using GLMakie, TDAplots
using MetricSpaces.Datasets: sphere

X = sphere(200, dim=2)
fv = first.(X)
ic = TDAmapper.ImageCovers.R1Cover(fv, TDAmapper.IntervalCovers.Uniform(length=5, expansion=0.3))
M = classical_mapper(X, ic, TDAmapper.Refiners.DBscan(radius=0.2))

res = mapper_explorer(M; inspector=true)
res.figure                      # the figure (hover a node, or click it)
res.selected_node[] = 3         # programmatically select node 3
res.selected_node[] = nothing   # clear the selection
```
"""
function mapper_explorer(
    M::AbstractMapper;
    data=nothing,
    node_values=nothing,
    node_size=nothing,
    colormap=:viridis,
    edge_size=1,
    layout_function=NetworkLayout.Spring(dim=2),
    markersize=6,
    dims=nothing,
    inspector=false
)
    g = M.g
    C = M.C

    node_positions, node_size, node_values, dim =
        _node_geometry(M; node_size=node_size, node_values=node_values,
            layout_function=layout_function)

    node_values isa Vector{<:Number} ||
        error("mapper_explorer only supports numeric node_values; got $(typeof(node_values)). Use mapper_plot for categorical coloring.")

    data_positions, data_ndims = _data_positions(M; data=data, dims=dims)
    n_nodes = length(node_positions)
    n_points = length(data_positions)

    # The selection observable everything else reacts to.
    selected_node = Observable{Union{Nothing,Int}}(nothing)

    fig = Figure()

    # --- LEFT panel: mapper graph -------------------------------------------
    ax_graph = dim == 2 ? Axis(fig[1, 1]; title="Mapper graph") :
        Axis3(fig[1, 1]; title="Mapper graph")

    if ne(g) > 0
        PT = eltype(node_positions)
        edge_pts = PT[]
        for e in edges(g)
            push!(edge_pts, node_positions[e.src], node_positions[e.dst])
        end
        linesegments!(ax_graph, edge_pts; color=:black, linewidth=edge_size)
    end

    cr = extrema(node_values)

    # Stroke widths mark the selected node on the graph.
    node_strokewidths = lift(selected_node) do sel
        sw = fill(0.0, n_nodes)
        if !isnothing(sel) && 1 <= sel <= n_nodes
            sw[sel] = 3.0
        end
        sw
    end

    node_plot = scatter!(ax_graph, node_positions;
        markersize=node_size, color=node_values,
        colormap=colormap, colorrange=cr,
        strokecolor=:red, strokewidth=node_strokewidths,
        inspectable=true,
        inspector_label=(plot, idx, pos) -> begin
            i = clamp(idx, 1, n_nodes)
            "node $i\n$(length(C[i])) points\nvalue ≈ $(round(node_values[i]; digits=3))"
        end)

    Colorbar(fig[1, 2]; colormap=colormap, colorrange=cr)

    hidedecorations!(ax_graph)
    hidespines!(ax_graph)

    # --- RIGHT panel: data scatter ------------------------------------------
    ax_data = data_ndims == 2 ? Axis(fig[1, 3]; title="Data") :
        Axis3(fig[1, 3]; title="Data")

    default_color = RGBAf(0.2, 0.4, 0.8, 1.0)
    highlight_color = RGBAf(0.85, 0.15, 0.15, 1.0)
    dim_color = RGBAf(0.6, 0.6, 0.6, 0.15)

    # Point colors react to the selected node: members highlighted, others dimmed.
    point_colors = lift(selected_node) do sel
        if isnothing(sel) || !(1 <= sel <= n_nodes)
            return fill(default_color, n_points)
        end
        members = Set(C[sel])
        [i in members ? highlight_color : dim_color for i in 1:n_points]
    end

    scatter!(ax_data, data_positions; color=point_colors, markersize=markersize)

    hidedecorations!(ax_data)
    hidespines!(ax_data)

    colsize!(fig.layout, 1, Relative(0.45))
    colsize!(fig.layout, 3, Relative(0.45))

    # --- Click interaction ---------------------------------------------------
    # Clicking a graph node selects it; clicking empty space clears the selection.
    on(events(ax_graph.scene).mousebutton) do event
        if event.button == Mouse.left && event.action == Mouse.press
            plt, idx = pick(ax_graph.scene)
            if plt === node_plot && idx >= 1 && idx <= n_nodes
                selected_node[] = idx
            else
                selected_node[] = nothing
            end
        end
        return Consume(false)
    end

    # --- Optional hover tooltips --------------------------------------------
    if inspector
        # DataInspector requires an interactive screen; on non-interactive
        # backends (e.g. CairoMakie) this is effectively a no-op, so guard it.
        try
            DataInspector(fig)
        catch
            # no-op on backends without interactive picking
        end
    end

    return MapperExplorer(fig, selected_node)
end
