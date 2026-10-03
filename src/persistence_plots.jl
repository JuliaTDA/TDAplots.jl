"""
    _dim_str(diag)

Format the dimension of a `PersistenceDiagram` as a subscript string (e.g. H₀, H₁).
"""
function _dim_str(diag)
    sub_digits = ("₀", "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉")
    if hasproperty(diag, :dim)
        return join(reverse(sub_digits[digits(dim(diag)) .+ 1]))
    else
        return "ₓ"
    end
end

function _clamp_death(int::PersistenceInterval, t_max)
    return isfinite(int) ? death(int) : t_max
end

function _clamp_persistence(int::PersistenceInterval, t_max)
    return isfinite(int) ? persistence(int) : t_max
end

"""
    _diagram_limits(diags, infinity=nothing)

Compute axis limits and infinity value for a collection of persistence diagrams.
Returns `(t_lo, t_hi, infinity)`.
"""
function _diagram_limits(diags, infinity=nothing)
    t_lo = Inf
    t_hi = -Inf
    has_infinite = false

    for diag in diags
        for int in diag
            b = birth(int)
            t_lo = min(t_lo, b)
            if isfinite(int)
                d = death(int)
                t_lo = min(t_lo, d)
                t_hi = max(t_hi, b, d)
            else
                has_infinite = true
                t_hi = max(t_hi, b)
            end
        end
    end

    if t_lo == Inf
        t_lo = 0.0
    end
    if t_hi == -Inf
        t_hi = 1.0
    end

    if isnothing(infinity)
        # Try to use threshold from diagram metadata
        threshes = Float64[]
        for diag in diags
            if hasproperty(diag, :threshold) && isfinite(threshold(diag))
                push!(threshes, threshold(diag))
            end
        end
        infinity = isempty(threshes) ? t_hi * 1.25 : maximum(threshes)
    end

    if has_infinite
        t_hi = infinity
    end

    gap = (t_hi - t_lo) * 0.05
    if gap ≈ 0
        gap = 0.1
    end

    (t_lo - gap, t_hi + gap, infinity)
end

"""
    persistence_plot(diags; persistence=false, infinity=nothing, markersize=10)

Plot a persistence diagram using Makie.

Accepts a single `PersistenceDiagram` or a `Vector{PersistenceDiagram}` (e.g. from TDARipserer).
Points are colored by homology dimension.

# Keyword Arguments
- `persistence`: if `true`, plot (birth, persistence) instead of (birth, death). Default: `false`.
- `infinity`: value at which to clamp infinite intervals. Auto-detected if `nothing`.
- `markersize`: marker size for scatter points. Default: `10`.
"""
function persistence_plot(
    diags::Union{PersistenceDiagram, AbstractVector{PersistenceDiagram}};
    persistence::Bool=false,
    infinity=nothing,
    markersize=10,
)
    if diags isa PersistenceDiagram
        diags = [diags]
    end

    lo, hi, inf_val = _diagram_limits(diags, infinity)

    f = Figure()
    ax = Axis(f[1, 1],
        xlabel="birth",
        ylabel=persistence ? "persistence" : "death",
        title="Persistence Diagram",
        aspect=DataAspect(),
    )

    # Reference line: diagonal y=x or y=0
    if persistence
        hlines!(ax, [0.0]; color=:black, linewidth=0.5)
    else
        lines!(ax, [lo, hi], [lo, hi]; color=:black, linewidth=0.5)
    end

    # Group by dimension and plot
    different_dims = all(d -> hasproperty(d, :dim), diags) && allunique(dim.(diags))

    for (i, diag) in enumerate(diags)
        isempty(diag) && continue

        xs = birth.(diag)
        ys = if persistence
            [_clamp_persistence(int, inf_val) for int in diag]
        else
            [_clamp_death(int, inf_val) for int in diag]
        end

        label = if different_dims
            "H$(_dim_str(diag))"
        else
            "H$(_dim_str(diag)) ($i)"
        end

        scatter!(ax, xs, ys; markersize=markersize, label=label)
    end

    # Infinity line (dashed grey)
    has_infinite = any(diag -> any(!isfinite, diag), diags)
    if has_infinite
        if persistence
            hlines!(ax, [inf_val]; color=:grey, linestyle=:dot, linewidth=1, label="∞")
        else
            hlines!(ax, [inf_val]; color=:grey, linestyle=:dot, linewidth=1, label="∞")
        end
    end

    xlims!(ax, lo, hi)
    ylims!(ax, lo, hi)

    if length(diags) > 1 || has_infinite
        Legend(f[1, 2], ax; merge=true)
    end

    return f
end

"""
    barcode_plot(diags; infinity=nothing)

Plot a persistence barcode using Makie.

Accepts a single `PersistenceDiagram` or a `Vector{PersistenceDiagram}`.
Bars are colored by homology dimension.

# Keyword Arguments
- `infinity`: value at which to clamp infinite intervals. Auto-detected if `nothing`.
"""
function barcode_plot(
    diags::Union{PersistenceDiagram, AbstractVector{PersistenceDiagram}};
    infinity=nothing,
)
    if diags isa PersistenceDiagram
        diags = [diags]
    end

    lo, hi, inf_val = _diagram_limits(diags, infinity)

    f = Figure()
    ax = Axis(f[1, 1],
        xlabel="t",
        title="Persistence Barcode",
    )
    hideydecorations!(ax)

    different_dims = all(d -> hasproperty(d, :dim), diags) && allunique(dim.(diags))
    bar_offset = 0

    for (i, diag) in enumerate(diags)
        isempty(diag) && continue

        label = if different_dims
            "H$(_dim_str(diag))"
        else
            "H$(_dim_str(diag)) ($i)"
        end

        xs = Float64[]
        ys = Float64[]
        for int in diag
            bar_offset += 1
            b = birth(int)
            d = _clamp_death(int, hi)
            append!(xs, (b, d, NaN))
            append!(ys, (bar_offset, bar_offset, NaN))
        end

        lines!(ax, xs, ys; linewidth=1, label=label)
    end

    # Infinity line (dashed grey vertical)
    has_infinite = any(diag -> any(!isfinite, diag), diags)
    if has_infinite
        vlines!(ax, [inf_val]; color=:grey, linestyle=:dot, linewidth=1, label="∞")
    end

    xlims!(ax, lo, hi)

    if length(diags) > 1 || has_infinite
        Legend(f[1, 2], ax; merge=true)
    end

    return f
end
