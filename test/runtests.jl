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

@testitem "Scientific formatting" setup=[Setup] begin
    x = scientific(1e-3, 1)
    @test x == "1.0 × 10⁻³"
    x = scientific(1e-3, 0)
    @test x == "1 × 10⁻³"
    x = scientific(π, 5)
    @test x == "3.14159"
    x = scientific(-π * 10^-6, 3)
    @test x == "-3.142 × 10⁻⁶"

    x = lscientific(1e-3, 1)
    @test x == "1.0\\times 10^{-3}"
    x = lscientific(1e-3, 0)
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

@testitem "Ziggurat plot" setup=[Setup] begin
    x = randn(1000)
    y = randn(1000) .+ 2
    f = Figure()
    ax = Axis(f[1, 1])
    ziggurat!(ax, x .- 1; normalization = :probability)
    ziggurat!(ax, x; normalization = :probability)
    ziggurat!(ax, y; color = :green, bins = 50, normalization = :pdf, linewidth = 4)
    display(f)
end

@testitem "Hill plot" setup=[Setup] begin
    x = randn(1000)
    y = randn(1000) .+ 2
    f = Figure()
    ax = Axis(f[1, 1])
    hill!(ax, x .- 1)
    hill!(ax, x)
    hill!(ax, y; color = :red, bandwidth = 0.01, strokewidth = 5)
    display(f)
end

@testitem "Bandwidth plot" setup=[Setup] begin
    x = range(-4π, 4π, length = 1000)
    y = sinc.(x)
    f = Figure()
    ax = Axis(f[1, 1])
    bandwidth!(ax, x, y; bandwidth = range(0.0001, 0.1, length = length(x)))

    bandwidth!(ax, x, y .+ 0.25; bandwidth = range(0.5, 0.00, length = length(x)),
               direction = :y, alpha = 0.5)
    display(f)
end

@testitem "Polar histogram" setup=[Setup] begin
    x = [rand(Distributions.VonMises(-3, 10), 10000); rand(VonMises(1, 10), 10000)]

    f = Figure()
    ax = PolarAxis(f[1, 1])
    polarhist!(ax, x; bins = 100, strokewidth = 0)
    hist!(ax, x; bins = 100, strokewidth = 0, color = (:red, 0.1)) # Messed up
    display(f)
end

@testitem "Polar density" setup=[Setup] begin
    x = [rand(Distributions.VonMises(-3, 10), 10000); rand(VonMises(1, 10), 10000)]
    f = Figure()
    ax = PolarAxis(f[1, 1])
    polardensity!(ax, x; strokewidth = 10, strokecolor = bermejo)
    display(f)

    x = randn(1000) .* 2
    f = Figure()
    ax = PolarAxis(f[1, 1])
    polardensity!(ax, x; strokewidth = 5, strokecolor = :angle,
                  strokecolormap = cyclic, alpha = 0.5)
    display(f)
end

@testitem "addlabels!" setup=[Setup] begin
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
    @test_nowarn addlabels!(f, string.(1:6))
    @test_nowarn display(f)

    f = Fathom.demofigure()
    @test_nowarn addlabels!(f, i -> "[$i]")
    @test_nowarn display(f)
end

@testitem "Demo figure" setup=[Setup] begin
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

    save("./palette.svg", cgrad(first.(Fathom.palette[1]), categorical = true))

    for (name, c) in Fathom.fathom_colormaps
        save("./colormaps/$name.svg", c)
    end
    @test_nowarn freeze!(f)
end

@testitem "Seethrough" setup=[Setup] begin
    C = sunrise
    transparent_gradient = seethrough(C)
    @test transparent_gradient isa PlotUtils.ContinuousColorGradient
    transparent_gradient = @test_nowarn seethrough(C, 0.5, 1.0)
    @test transparent_gradient isa PlotUtils.ContinuousColorGradient
end

@testitem "Write base colors to YAML" setup=[Setup] begin
    using YAML

    function tohex(c)
        rgb = convert(CairoMakie.Makie.RGB, c)
        r = round(Int, clamp(rgb.r, 0, 1) * 255)
        g = round(Int, clamp(rgb.g, 0, 1) * 255)
        b = round(Int, clamp(rgb.b, 0, 1) * 255)
        return uppercase(string("#", string(r, base = 16, pad = 2),
                                string(g, base = 16, pad = 2),
                                string(b, base = 16, pad = 2)))
    end

    data = Dict{String, Dict{String, String}}()
    for (name, base) in pairs(Fathom.BASE_COLORS)
        data[String(name)] = Dict("base" => tohex(base),
                                  "light" => tohex(Fathom.light(base)),
                                  "dark" => tohex(Fathom.dark(base)))
    end

    path = joinpath(@__DIR__, "colors.yaml")
    YAML.write_file(path, data)
    @test isfile(path)

    loaded = YAML.load_file(path)
    for (name, _) in pairs(Fathom.BASE_COLORS)
        key = String(name)
        @test haskey(loaded, key)
        @test haskey(loaded[key], "base")
        @test haskey(loaded[key], "light")
        @test haskey(loaded[key], "dark")
    end
end

@testitem "HSLuv conversion" setup=[Setup] begin
    c = RGB(0.2, 0.6, 0.8)
    h = hsluv(c)
    @test h isa HSLuv
    @test 0 <= h.s <= 100
    @test 0 <= h.l <= 100

    c2 = convert(RGB, h)
    @test c2.r≈c.r atol=2e-3
    @test c2.g≈c.g atol=2e-3
    @test c2.b≈c.b atol=2e-3

    w = hsluv(RGB(1, 1, 1))
    b = hsluv(RGB(0, 0, 0))
    @test w.s≈0 atol=1e-8
    @test w.l≈100 atol=1e-8
    @test b.s≈0 atol=1e-8
    @test b.l≈0 atol=1e-8

    # ColorTypes integration: HSLuv must be a proper Color{T,3}
    @test HSLuv <: Colors.Color
    @test HSLuv{Float64} <: Colors.Color{Float64, 3}
    @test eltype(h) === Float64
    @test length(h) == 3

    # Parametric element type and constructor promotion
    hf32 = HSLuv{Float32}(10.0f0, 50.0f0, 60.0f0)
    @test eltype(hf32) === Float32
    @test HSLuv(10, 50, 60) isa HSLuv{Float64}
    @test HSLuv(10.0f0, 50.0f0, 60.0f0) isa HSLuv{Float32}

    # Round-trip via the ColorTypes convert machinery at multiple element types
    rgb32 = convert(RGB{Float32}, h)
    @test rgb32 isa RGB{Float32}
    @test rgb32.r≈c.r atol=2e-3
    h_back = convert(HSLuv{Float32}, rgb32)
    @test h_back isa HSLuv{Float32}
    @test h_back.h≈h.h atol=1e-2
    @test h_back.s≈h.s atol=1e-2
    @test h_back.l≈h.l atol=1e-2

    # Conversion from other Colors.jl spaces should work via the cnvt fallback
    lab = convert(Lab, c)
    h_from_lab = convert(HSLuv, lab)
    @test h_from_lab.l≈h.l atol=1e-6
    @test h_from_lab.h≈h.h atol=1e-6
    @test convert(XYZ, h) isa XYZ

    # HSLuv should be usable anywhere a Colorant is expected
    @test Makie.to_color(h) isa Colors.Colorant
end

@testitem "HSLuv luminance matching" setup=[Setup] begin
    colors = [baikal, bermejo, qinghai, seohae, ianthina, abyad]
    lref = hsluv(baikal).l
    ltarget = 80.0

    warped_rgb = set_hsluv(colors; l = ltarget)
    @test length(warped_rgb) == length(colors)

    warped = set_hsluv(colors; l = ltarget, outtype = HSLuv)
    @test length(warped) == length(colors)

    for i in eachindex(colors)
        @test warped[i].l≈ltarget atol=2e-3
        @test warped[i].h≈hsluv(colors[i]).h atol=2e-3
    end

    lref2 = hsluv(abyad).l
    warped2 = set_hsluv(colors; l = lref2, outtype = HSLuv)
    @test length(warped2) == length(colors)
    @test all(c -> isapprox(c.l, lref2; atol = 2e-3), warped2)

    warped3 = set_hsluv(colors; h = 120, s = 20, l = 65, outtype = HSLuv)
    @test length(warped3) == length(colors)
    @test all(c -> isapprox(c.h, 120; atol = 2e-3), warped3)
    @test all(c -> isapprox(c.s, 20; atol = 2e-3), warped3)
    @test all(c -> isapprox(c.l, 65; atol = 2e-3), warped3)

    warped4 = set_hsluv(colors; l = 55, outtype = HSLuv)
    @test all(c -> isapprox(c.l, 55; atol = 2e-3), warped4)
end

@testitem "Swatches" setup=[Setup] begin
    include("./swatches.jl")
end

@testitem "Colormaps" setup=[Setup] begin
    include("./colormaps.jl")
end

@testitem "Prism plots" setup=[Setup] begin
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
    axislegend(ax,
               [
                   PolyElement(color = (baikal, 0.7)),
                   PolyElement(color = (bermejo, 0.7))
               ],
               ["PC 1", "PC 2"], position = :lt)
    ax.xlabel = ax.ylabel = "Variable"
    f
    save("./recipes/prism_light.png", f; px_per_unit = 5)

    Makie.set_theme!(fathom(:dark, :transparent))
    f = OnePanel()
    limits = (0, maximum(abs.(Σ²)))
    g, ax = prismplot!(f[1, 1], H; limits, colorbarlabel = "Covariance magnitude")
    axislegend(ax,
               [
                   PolyElement(color = (baikal, 0.7)),
                   PolyElement(color = (bermejo, 0.7))
               ],
               ["PC 1", "PC 2"], position = :lt)
    ax.xlabel = ax.ylabel = "Variable"
    f
    save("./recipes/prism_dark.png", f; px_per_unit = 5)
end

@testitem "covellipse" setup=[Setup] begin
    x = randn(10000)
    y = x .+ 0.5 .* randn(10000)
    xy = hcat(x, y)
    μ = mean(xy, dims = 1)
    Σ² = cov(xy)

    Makie.set_theme!(fathom())
    f = Figure()
    ax = Axis(f[1, 1]; xlabel = "x", ylabel = "y")
    @test_nowarn covellipse!(ax, μ, Σ², color = (baikal, 0.1),
                             strokecolor = baikal,
                             strokewidth = 5, scale = 2)
    scatter!(ax, x, y; markersize = 2, color = (baikal, 0.42))
    save("./recipes/covellipse_light.png", f; px_per_unit = 5)

    Makie.set_theme!(fathom(:dark, :transparent))
    f = Figure()
    ax = Axis(f[1, 1]; xlabel = "x", ylabel = "y")
    @test_nowarn covellipse!(ax, μ, Σ², color = (baikal, 0.1),
                             strokecolor = baikal,
                             strokewidth = 5, scale = 2)
    scatter!(ax, x, y; markersize = 2, color = (baikal, 0.42))
    save("./recipes/covellipse_dark.png", f; px_per_unit = 5)
end

@testitem "Importall" setup=[Setup] begin # Keep this at the end
    @test all(isnothing.(eval.(importall(Fathom))))
    Makie.set_theme!(fathom())
    save("./demos/default.png", demofigure(), px_per_unit = 5)
end
