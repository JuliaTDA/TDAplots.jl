using TDAplots
using Test
using Graphs: nv, ne

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
end
