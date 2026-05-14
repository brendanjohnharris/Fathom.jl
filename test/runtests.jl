using Test
using TestItems
using TestItemRunner

@run_package_tests

@testsnippet Setup begin
    using CairoMakie
    using CairoMakie.Makie.PlotUtils
    using Statistics
    using LinearAlgebra
    using Fathom
    using CairoMakie.Makie.Distributions
    using LaTeXStrings
end

@testitem "Scientific formatting" setup = [Setup] begin
    x = scientific(1.0e-3, 1)
    @test x == "1.0 × 10⁻³"
    x = scientific(1.0e-3, 0)
    @test x == "1 × 10⁻³"
    x = scientific(π, 5)
    @test x == "3.14159"
    x = scientific(-π * 10^-6, 3)
    @test x == "-3.142 × 10⁻⁶"

    x = lscientific(1.0e-3, 1)
    @test x == "1.0\\times 10^{-3}"
    x = lscientific(1.0e-3, 0)
    @test x == "1\\times 10^{-3}"
    x = lscientific(π, 5)
    @test x == "3.14159"
    x = lscientific(-π * 10^-6, 3)
    @test x == "-3.142\\times 10^{-6}"

    x = (rand(1000) .- 0.5) .* 10 .|> exp10
    @test_nowarn scientific.(x)
    @test_nowarn lscientific.(x)
    @test_nowarn Lscientific.(x)
end

@testitem "Ziggurat plot" setup = [Setup] begin
    x = randn(1000)
    y = randn(1000) .+ 2
    f = Figure()
    ax = Axis(f[1, 1])
    ziggurat!(ax, x .- 1; normalization = :probability)
    ziggurat!(ax, x; normalization = :probability)
    ziggurat!(ax, y; color = :green, bins = 50, normalization = :pdf, linewidth = 4)
    display(f)
end

@testitem "Bandwidth plot" setup = [Setup] begin
    x = range(-4π, 4π, length = 1000)
    y = sinc.(x)
    f = Figure()
    ax = Axis(f[1, 1])
    bandwidth!(ax, x, y; bandwidth = range(0.0001, 0.1, length = length(x)))

    bandwidth!(
        ax, x, y .+ 0.25; bandwidth = range(0.5, 0.0, length = length(x)),
        direction = :y, alpha = 0.5
    )
    display(f)
end

@testitem "Polar histogram" setup = [Setup] begin
    x = [rand(Distributions.VonMises(-3, 10), 10000); rand(VonMises(1, 10), 10000)]

    f = Figure()
    ax = PolarAxis(f[1, 1])
    polarhist!(ax, x; bins = 100, strokewidth = 0)
    hist!(ax, x; bins = 100, strokewidth = 0, color = (:red, 0.1)) # Messed up
    display(f)
end

@testitem "Polar density" setup = [Setup] begin
    x = [rand(Distributions.VonMises(-3, 10), 10000); rand(VonMises(1, 10), 10000)]
    f = Figure()
    ax = PolarAxis(f[1, 1])
    polardensity!(ax, x; strokewidth = 10, strokecolor = bermejo)
    display(f)

    x = randn(1000) .* 2
    f = Figure()
    ax = PolarAxis(f[1, 1])
    polardensity!(
        ax, x; strokewidth = 5, strokecolor = :angle,
        strokecolormap = cyclic, alpha = 0.5
    )
    display(f)
end

@testitem "addlabels!" setup = [Setup] begin
    f = Figure()
    gps = subdivide(f, 2, 2)
    @test_nowarn addlabels!(gps)
    @test_nowarn display(f)

    f = Fathom.demofigure()
    @test_nowarn addlabels!(f)
    @test_nowarn display(f)

    f = Fathom.demofigure()
    @test_nowarn addlabels!(f; dims = 1)
    @test_nowarn display(f)

    f = Fathom.demofigure()
    @test_nowarn addlabels!(f, string.(1:12))
    @test_nowarn display(f)

    f = Fathom.demofigure()
    @test_nowarn addlabels!(f, i -> "[$i]")
    @test_nowarn display(f)
end

@testitem "Demo figure" setup = [Setup] tags = [:demo] begin

    for f in readdir(joinpath(@__DIR__, "demos"); join = true)
        endswith(f, ".png") && rm(f)
    end

    @test_nowarn Makie.set_theme!(fathom())
    f = Fathom.demofigure()
    addlabels!(f)
    save("./demos/demo.png", f, px_per_unit = 5)

    @test_nowarn Makie.set_theme!(fathom(:dark))
    f = Fathom.demofigure()
    addlabels!(f)
    save("./demos/dark.png", f, px_per_unit = 5)

    @test_nowarn Makie.set_theme!(fathom(:dark, :transparent))
    f = Fathom.demofigure()
    addlabels!(f)
    save("./demos/transparent.png", f, px_per_unit = 5)

    Makie.set_theme!(fathom(:serif))
    f = Fathom.demofigure()
    addlabels!(f)
    save("./demos/serif.png", f, px_per_unit = 5)

    Makie.set_theme!(fathom(:physics))
    f = Fathom.demofigure()
    addlabels!(f)
    save("./demos/physics.png", f, px_per_unit = 5)

    save("./palette.svg", cgrad(Fathom.colororder, categorical = true))

    for (name, c) in Fathom.fathom_colormaps
        save("./colormaps/$name.svg", c)
    end
    @test_nowarn freeze!(f)
end

@testitem "Seethrough" setup = [Setup] begin
    C = sunrise
    transparent_gradient = seethrough(C)
    @test transparent_gradient isa PlotUtils.ContinuousColorGradient
    transparent_gradient = @test_nowarn seethrough(C, 0.5, 1.0)
    @test transparent_gradient isa PlotUtils.ContinuousColorGradient
end

@testitem "Write base colors to YAML" setup = [Setup] tags = [:demo] begin
    include("./generate_yaml.jl")
end

@testitem "Swatches" setup = [Setup] tags = [:demo] begin
    include("./swatches.jl")
end

@testitem "Colormaps" setup = [Setup] tags = [:demo] begin
    include("./colormaps.jl")
end

@testitem "Prism plots" setup = [Setup] tags = [:demo] begin
    f = 1:100
    x = randn(1000, 4)
    y = x * [1.0; 0.5; 0.01; 1.5] .+
        randn(1000, 4) *
        [1.0 0.04 0.09 0.4; 0.04 1.0 0.01 0.1; 0.09 0.01 1.0 0.2; 0.4 0.1 0.2 1.0]
    z = [x y]
    Σ² = cov(z; dims = 1)
    # heatmap(Σ²; colormap=:binary)

    @test_nowarn H = prism(Σ²)

    xs = 0:0.001:(π * 1.5)
    ys = [sin.(xs .+ i) for i in 0.1:0.1:(2π)]
    ys = hcat(ys...)
    ys = ys + randn(size(ys)) ./ 10
    Σ² = cov(ys; dims = 1)
    H = prism(Σ²; palette = [baikal, bermejo])

    Makie.set_theme!(fathom())
    f = OnePanel()
    limits = (0, maximum(abs.(Σ²)))
    g, ax = prismplot!(f[1, 1], H; limits, colorbarlabel = "Covariance magnitude")
    axislegend(
        ax,
        [
            PolyElement(color = (baikal, 0.7)),
            PolyElement(color = (bermejo, 0.7)),
        ],
        ["PC 1", "PC 2"], position = :lt
    )
    ax.xlabel = ax.ylabel = "Variable"
    f
    save("./recipes/prism_light.png", f; px_per_unit = 5)

    Makie.set_theme!(fathom(:dark, :transparent))
    f = OnePanel()
    limits = (0, maximum(abs.(Σ²)))
    g, ax = prismplot!(f[1, 1], H; limits, colorbarlabel = "Covariance magnitude")
    axislegend(
        ax,
        [
            PolyElement(color = (baikal, 0.7)),
            PolyElement(color = (bermejo, 0.7)),
        ],
        ["PC 1", "PC 2"], position = :lt
    )
    ax.xlabel = ax.ylabel = "Variable"
    f
    save("./recipes/prism_dark.png", f; px_per_unit = 5)
end

@testitem "covellipse" setup = [Setup] tags = [:demo] begin
    x = randn(10000)
    y = x .+ 0.5 .* randn(10000)
    xy = hcat(x, y)
    μ = mean(xy, dims = 1)
    Σ² = cov(xy)

    Makie.set_theme!(fathom())
    f = Figure()
    ax = Axis(f[1, 1]; xlabel = "x", ylabel = "y")
    @test_nowarn covellipse!(
        ax, μ, Σ², color = (baikal, 0.1),
        strokecolor = baikal,
        strokewidth = 5, scale = 2
    )
    scatter!(ax, x, y; markersize = 2, color = (baikal, 0.42))
    save("./recipes/covellipse_light.png", f; px_per_unit = 5)

    Makie.set_theme!(fathom(:dark, :transparent))
    f = Figure()
    ax = Axis(f[1, 1]; xlabel = "x", ylabel = "y")
    @test_nowarn covellipse!(
        ax, μ, Σ², color = (baikal, 0.1),
        strokecolor = baikal,
        strokewidth = 5, scale = 2
    )
    scatter!(ax, x, y; markersize = 2, color = (baikal, 0.42))
    save("./recipes/covellipse_dark.png", f; px_per_unit = 5)
end

@testitem "Importall" setup = [Setup] begin # Keep this at the end
    @test all(isnothing.(eval.(importall(Fathom))))
    Makie.set_theme!(fathom())
    save("./demos/default.png", demofigure(), px_per_unit = 5)
end
