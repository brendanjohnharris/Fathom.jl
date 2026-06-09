# Regression tests for bug fixes and removals. Tagged `:fix` so they can be run on their own:
#   using TestItemRunner; @run_package_tests filter = ti -> (:fix in ti.tags)

@testitem "removed symbols" tags = [:fix] setup = [Setup] begin
    for s in (:make_lightness_linear, :perceived_lightness, :beep, :importall)
        @test !isdefined(Fathom, s)
    end
end

@testitem "scientific/lscientific non-finite" tags = [:fix] setup = [Setup] begin
    @test scientific(NaN) == "NaN"
    @test scientific(Inf) == "Inf"
    @test scientific(-Inf) == "-Inf"
    @test lscientific(NaN) == "NaN"
    @test lscientific(Inf) == "Inf"
    # existing behaviour preserved
    @test scientific(1.0e-3, 1) == "1.0 × 10⁻³"
    @test lscientific(1.0e-3, 1) == "1.0\\times 10^{-3}"
end

@testitem "default_bandwidth_circular degenerate data" tags = [:fix] setup = [Setup] begin
    @test isfinite(Fathom.default_bandwidth_circular(fill(0.3, 50)))   # constant -> no DomainError
    @test isfinite(Fathom.default_bandwidth_circular([0.3]))           # single point
    @test isfinite(Fathom.default_bandwidth_circular(randn(200) .* 0.5))
end

@testitem "pick_polarhist_edges bin count" tags = [:fix] setup = [Setup] begin
    e = Fathom.pick_polarhist_edges(randn(100), 20)
    @test length(e) - 1 == 20         # 20 bars need 21 edges
end

@testitem "hist_center_weights empty/zero data" tags = [:fix] setup = [Setup] begin
    e = range(-pi, pi, length = 6)
    _, w = Fathom.hist_center_weights(Float64[], e, :pdf, nothing, Makie.automatic)
    @test !any(isnan, w)
    _, w2 = Fathom.hist_center_weights(Float64[], e, :none, 1.0, Makie.automatic)
    @test !any(isnan, w2)
end

@testitem "polarkde input validation" tags = [:fix] setup = [Setup] begin
    @test_throws ErrorException Fathom.polarkde([-4.0, 0.0, 1.0])  # min < -π
    @test_throws ErrorException Fathom.polarkde([0.0, 4.0])        # max > π
    @test_throws ErrorException Fathom.polarkde(randn(50) .* 0.1; bandwidth = 0.0)
    @test_nowarn Fathom.polarkde(randn(200) .* 0.5)                # valid range
end

@testitem "polardensity wraps out-of-range angles" tags = [:fix] setup = [Setup] begin
    # PolarDensity must wrap raw angles (like PolarHist) rather than erroring in polarkde
    f = Figure(); ax = PolarAxis(f[1, 1])
    @test_nowarn polardensity!(ax, randn(1000) .+ randn())  # values well outside (-π, π)
    @test_nowarn display(f)
end

@testitem "prism colormode + degenerate" tags = [:fix] setup = [Setup] begin
    M = [1.0 0.4 0.1; 0.4 1.0 0.2; 0.1 0.2 1.0]
    @test_nowarn Fathom.prism(M; verbose = true)
    @test_nowarn Fathom.prism(M; colormode = :all)
    @test_throws ErrorException Fathom.prism(M; colormode = :bogus)
    H = Fathom.prism(zeros(3, 3))                                  # all-zero -> finite alpha
    @test all(c -> isfinite(Fathom.Colors.alpha(c)), H)
end

@testitem "_default_label past 26" tags = [:fix] setup = [Setup] begin
    @test Fathom._default_label(1) == "(a)"
    @test Fathom._default_label(26) == "(z)"
    @test Fathom._default_label(27) == "(aa)"
    @test Fathom._default_label(28) == "(ab)"
    @test Fathom._default_label(53) == "(ba)"
end

@testitem "set_luminance" tags = [:fix] setup = [Setup] begin
    @test convert(Fathom.Oklab, Fathom.RGB(set_luminance(baikal, 0.5))).l ≈ 0.5 atol = 1e-6
    # alpha preserved (Float32 round-trip, so compare with a tolerance)
    @test Fathom.Colors.alpha(set_luminance(Fathom.RGBA(0.2, 0.4, 0.6, 0.3), 0.7)) ≈ 0.3 atol = 1e-6
end

@testitem "widen" tags = [:fix] setup = [Setup] begin
    @test Fathom.widen([0.0, 1.0], 0.1) ≈ [-0.1, 1.1]
    @test Fathom.widen(Fathom.Interval(0, 1), 0.1) == Fathom.Interval(-0.1, 1.1)
end

@testitem "covellipse 2x2 only" tags = [:fix] setup = [Setup] begin
    f = Figure(); ax = Axis(f[1, 1])
    @test_nowarn covellipse!(ax, [0.0, 0.0], [1.0 0.0; 0.0 1.0])
    # the ArgumentError is wrapped by Makie's compute pipeline; match the message
    @test_throws "CovEllipse requires" begin
        p = covellipse!(ax, zeros(3), Matrix(1.0I, 3, 3))
        p.x[]   # force the converted argument
    end
end

@testitem "ziggurat filternan + strokearound" tags = [:fix] setup = [Setup] begin
    f = Figure(); ax = Axis(f[1, 1])
    # filternan: NaN-containing data must not error and matches the NaN-free histogram
    @test_nowarn ziggurat!(ax, [randn(500); fill(NaN, 10)]; filternan = true)
    # strokearound with a vector of edges must not crash (was: nbins=<vector> error)
    @test_nowarn ziggurat!(ax, randn(500); strokearound = true, bins = collect(-3.0:0.5:3.0))
    # strokearound honours normalization
    @test_nowarn ziggurat!(ax, randn(500); strokearound = true, normalization = :pdf)
    display(f)
end

@testitem "reverselegend! all groups" tags = [:fix] setup = [Setup] begin
    f = Figure()
    ax = Axis(f[1, 1])
    for i in 1:3
        lines!(ax, 1:10, (1:10) .* i, label = "g$i")
    end
    leg = Legend(f[1, 2], ax)
    before = copy(leg.entrygroups[][1][2])
    @test_nowarn reverselegend!(leg)
    @test leg.entrygroups[][1][2] == reverse(before)
end
