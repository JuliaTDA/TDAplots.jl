using TDAplots
using Aqua
using Test
using Graphs: nv, ne, SimpleGraph, add_edge!, path_graph
using MetricSpaces.Datasets: sphere
using MetricSpaces: EuclideanSpace
import Makie
using Makie: Point, Figure, Observable, to_value

Aqua.test_all(TDAplots)

@testset "TDAplots.jl" begin
    @testset "rescale" begin
        @test rescale([1.0, 2.0, 3.0]) ≈ [0.0, 0.5, 1.0]
        @test rescale([1.0, 2.0, 3.0]; min=10, max=20) ≈ [10.0, 15.0, 20.0]
        # Constant input
        r = rescale([5.0, 5.0, 5.0])
        @test all(r .≈ 0.5)
        # Curried version
        f = rescale(min=0, max=10)
        @test f([0.0, 0.5, 1.0]) ≈ [0.0, 5.0, 10.0]
    end

    @testset "colorscale" begin
        cs = colorscale([0.0, 0.5, 1.0])
        @test length(cs) == 3
        # Constant input should not error
        cs2 = colorscale([1.0, 1.0, 1.0])
        @test length(cs2) == 3
    end

    @testset "node_colors (numeric)" begin
        X = sphere(200, dim=2)
        fv = first.(X)
        ic = TDAmapper.ImageCovers.R1Cover(fv, TDAmapper.IntervalCovers.Uniform(length=5, expansion=0.3))
        M = classical_mapper(X, ic, TDAmapper.Refiners.DBscan(radius=0.2))

        # Default (first coordinate)
        nc = node_colors(M)
        @test length(nc) == length(M.C)
        @test nc isa Vector{<:Number}

        # Custom values
        nc2 = node_colors(M, fv)
        @test length(nc2) == length(M.C)
    end

    @testset "node_colors (categorical)" begin
        X = sphere(200, dim=2)
        fv = first.(X)
        ic = TDAmapper.ImageCovers.R1Cover(fv, TDAmapper.IntervalCovers.Uniform(length=5, expansion=0.3))
        M = classical_mapper(X, ic, TDAmapper.Refiners.DBscan(radius=0.2))

        labels = [x > 0 ? "pos" : "neg" for x in first.(X)]
        nc = node_colors(M, labels)
        @test length(nc) == length(M.C)
        @test nc isa Vector{<:AbstractString}
    end

    @testset "_mode_string" begin
        @test TDAplots._mode_string(["a", "b", "a"]) == "a"
        @test TDAplots._mode_string(["a", "b"]) == "a/b"
        @test TDAplots._mode_string(["x"]) == "x"
    end

    @testset "centroid" begin
        X = sphere(200, dim=2)
        fv = first.(X)
        ic = TDAmapper.ImageCovers.R1Cover(fv, TDAmapper.IntervalCovers.Uniform(length=5, expansion=0.3))
        M = classical_mapper(X, ic, TDAmapper.Refiners.DBscan(radius=0.2))

        ctd = centroid(M)
        @test size(ctd, 1) == 2  # 2D points
        @test size(ctd, 2) == length(M.C)
    end

    @testset "layout_landmarks" begin
        X = sphere(200, dim=2)
        fv = first.(X)
        ic = TDAmapper.ImageCovers.R1Cover(fv, TDAmapper.IntervalCovers.Uniform(length=5, expansion=0.3))
        M = classical_mapper(X, ic, TDAmapper.Refiners.DBscan(radius=0.2))

        pos = layout_landmarks(M)
        @test length(pos) == length(M.C)
        @test pos[1] isa Point{2}

        pos3 = layout_landmarks(M; dim=3)
        @test length(pos3) == length(M.C)
        # dim=3 on 2D data: d = min(3, 2) = 2, so still Point{2}
        @test pos3[1] isa Point{2}

        # dim=1 is invalid (d < 2) — must error
        @test_throws ErrorException layout_landmarks(M; dim=1)
    end

    @testset "layout_generic error" begin
        X = sphere(200, dim=2)
        fv = first.(X)
        ic = TDAmapper.ImageCovers.R1Cover(fv, TDAmapper.IntervalCovers.Uniform(length=5, expansion=0.3))
        M = classical_mapper(X, ic, TDAmapper.Refiners.DBscan(radius=0.2))

        # 4D output should throw (vcat doubles the rows: 2 → 4)
        @test_throws ErrorException layout_generic(M, x -> vcat(x, x))
    end

    @testset "mapper_explorer" begin
        # Use CairoMakie as a (non-interactive) backend so the figure renders.
        using CairoMakie
        CairoMakie.activate!()

        # Build a small Mapper directly: 20 points in 2D, 3 overlapping cover
        # elements, connected as a path graph (1 - 2 - 3).
        pts = [[Float64(i), Float64(i % 3)] for i in 1:20]
        X = EuclideanSpace(pts)
        C = [collect(1:8), collect(6:14), collect(12:20)]
        g = path_graph(3)
        M = Mapper(X=X, C=C, g=g)

        # --- Basic return shape -------------------------------------------
        res = mapper_explorer(M)
        @test res isa MapperExplorer
        @test res.figure isa Figure
        @test res.selected_node isa Observable
        @test res.selected_node[] === nothing
        # NamedTuple-like access / destructuring
        @test propertynames(res) == (:figure, :selected_node)

        # The right-panel point colors live in an Observable that reacts to the
        # selection. Reach the scatter plot for the data panel (ax_data is the
        # axis at fig[1, 3]).
        # Find the data scatter via the figure's content: we recompute the
        # color observable behavior by driving selected_node directly.
        # Capture the colors before selection.
        # The colors observable is internal; we validate behavior through a
        # locally rebuilt lift mirroring the implementation contract: members
        # of the selected node must be visually distinct from non-members.

        # --- Drive the observable: select node 2 --------------------------
        # Grab the data-panel scatter plot to read its color observable.
        data_scatter = nothing
        for ax in res.figure.content
            if ax isa Makie.Axis
                for p in ax.scene.plots
                    if p isa Makie.Scatter && length(p[1][]) == length(pts)
                        data_scatter = p
                    end
                end
            end
        end
        @test data_scatter !== nothing

        colors_default = copy(to_value(data_scatter.color))
        @test length(colors_default) == length(pts)
        @test all(c -> c == colors_default[1], colors_default)  # uniform when unselected

        res.selected_node[] = 2
        @test res.selected_node[] == 2
        colors_sel = copy(to_value(data_scatter.color))
        members = Set(C[2])
        member_colors = unique(colors_sel[collect(members)])
        nonmember_idx = [i for i in 1:length(pts) if !(i in members)]
        nonmember_colors = unique(colors_sel[nonmember_idx])
        # members and non-members must be colored differently
        @test isempty(intersect(Set(member_colors), Set(nonmember_colors)))
        # and the styling changed from the default (unselected) state
        @test colors_sel != colors_default

        # --- Reset to nothing ---------------------------------------------
        res.selected_node[] = nothing
        @test res.selected_node[] === nothing
        colors_reset = copy(to_value(data_scatter.color))
        @test colors_reset == colors_default

        # --- data= override ------------------------------------------------
        custom_data = [(rand(), rand()) for _ in 1:20]
        res2 = mapper_explorer(M; data=custom_data)
        @test res2.figure isa Figure
        @test res2.selected_node[] === nothing
        res2.selected_node[] = 1
        @test res2.selected_node[] == 1

        # --- 3D M.X --------------------------------------------------------
        pts3 = [[Float64(i), Float64(i % 3), Float64(i % 5)] for i in 1:20]
        X3 = EuclideanSpace(pts3)
        M3 = Mapper(X=X3, C=C, g=g)
        res3 = mapper_explorer(M3)
        @test res3.figure isa Figure
        @test res3.selected_node[] === nothing
        res3.selected_node[] = 3
        @test res3.selected_node[] == 3

        # --- inspector=true must not error on CairoMakie -------------------
        res4 = mapper_explorer(M; inspector=true)
        @test res4.figure isa Figure

        # --- categorical node_values is rejected ---------------------------
        @test_throws ErrorException mapper_explorer(M; node_values=["a", "b", "c"])
    end

    @testset "tomato_plots end-to-end" begin
        using ToMATo
        using MetricSpaces.Datasets: two_clusters
        using Makie: Figure, FigureAxisPlot
        using Random
        Random.seed!(42)

        X = two_clusters(200, dim=2, separation=10)
        g = ToMATo.proximity_graph(X, 1.5, max_k_ball=10, k_nn=5, min_k_ball=2)
        ds = ToMATo.knn_density(X, k=5)
        clusters, bds = ToMATo.tomato(X, g, ds, 0.1)

        fig1 = tomato_graph_plot(X, g, ds)
        @test fig1 isa Figure

        fig2 = tomato_persistence_plot(bds)
        @test fig2 isa FigureAxisPlot || fig2 isa Figure
    end
end
