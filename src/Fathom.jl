module Fathom

using Makie
using Format
using Colors
using Random
using ImageClipboard
using FileIO
using Preferences
using Makie.LaTeXStrings
import Makie.IntervalSets: Interval

export fathom, importall, freeze!, clip, axiscolorbar,
    reverselegend!,
    scientific, lscientific, Lscientific,
    percentageticks, terseticks

function __init__()
    return ENV["UNITFUL_FANCY_EXPONENTS"] = true
end

"""
    seethrough(C::ContinuousColorGradient, start=0.0, stop=1.0)

Convert a color gradient into a transparent version

# Examples
```julia
C = sunrise;
transparent_gradient = seethrough(C)
```
"""
function seethrough(C::Makie.PlotUtils.ContinuousColorGradient, start = 0, stop = 1.0)
    colors = C.colors
    alphas = LinRange(start, stop, length(colors))
    return cgrad([RGBA(RGB(c), a) for (c, a) in zip(colors, alphas)], C.values)
end
seethrough(C, args...) = seethrough(cgrad(C), args...)
seethrough(C::Makie.Color, args...) = seethrough(cgrad([C, C]), args...)
export seethrough

"""
    set_luminance(c, l)

Return a color equal to `c` but with its Oklab lightness replaced by `l`
(on Oklab's native `L ∈ [0, 1]` scale).
The chroma coordinates and any alpha channel on `c` are preserved.
"""
function set_luminance(c, l::Real)
    col = Makie.to_color(c)
    alpha = Colors.alpha(col)
    rgb = convert(RGB, col)
    ok = convert(Oklab, rgb)
    new_l = clamp(Float64(l), 0, 1)
    new_rgb = convert(RGB, Oklab(new_l, ok.a, ok.b))
    return RGBA(new_rgb.r, new_rgb.g, new_rgb.b, alpha)
end

"""
    lighten(c, β, δ = 0)

Create a lightened variant of color `c` by increasing Oklab lightness by `β`
and reducing chroma by factor `δ` on `[0, 1]`.
`δ = 0` keeps original chroma, `δ = 1` fully desaturates.
"""
function lighten(c, β::Real, δ::Real = 0)
    col = Makie.to_color(c)
    alpha = Colors.alpha(col)
    ok = convert(Oklab, convert(RGB, col))
    new_l = clamp(ok.l + Float64(β), 0.0, 1.0)
    chroma_scale = 1.0 - clamp(Float64(δ), 0.0, 1.0)
    new_rgb = convert(RGB, Oklab(new_l, ok.a * chroma_scale, ok.b * chroma_scale))
    return RGBA(new_rgb.r, new_rgb.g, new_rgb.b, alpha)
end

"""
    darken(c, β, γ)

Darken a color `c` by subtracting an absolute Oklab lightness shift `β`
and apply a chroma boost `γ` on `[0, 1]` (0 means no boost).
Useful for richer dark variants that avoid looking washed out.
"""
function darken(c, β::Real, γ::Real = 0)
    col = Makie.to_color(c)
    alpha = Colors.alpha(col)
    ok = convert(Oklab, convert(RGB, col))
    new_l = clamp(ok.l - Float64(β), 0.0, 1.0)
    chroma_scale = 1.0 + clamp(Float64(γ), 0.0, 1.0)
    new_rgb = convert(RGB, Oklab(new_l, ok.a * chroma_scale, ok.b * chroma_scale))
    return RGBA(new_rgb.r, new_rgb.g, new_rgb.b, alpha)
end

const brighten = lighten
export lighten, darken, brighten, set_luminance

include("Colors.jl")
include("Colormaps.jl")
include("Recipes.jl")
include("Fonts.jl")


"""
Slightly widen an interval by a fraction δ
"""
function widen(x, δ = 0.05)
    @assert length(x) == 2
    Δ = diff(x |> collect)[1]
    return x .+ δ * Δ .* [-1, 1]
end
widen(i::Interval, args...) = Interval(widen(extrema(i), args...)...)

"""
    @default_theme!(thm)

Set the default theme to `thm` and save it as a preference. The change will take effect after restarting Julia.

# Example
```julia
    @default_theme!(fathom())
```
"""
macro default_theme!(thm)
    return try
        @set_preferences!("default_theme" => string(thm))
        @info("Default theme set to $thm. Restart Julia for the change to take effect")
    catch e
        @error "Could not set theme. Reverting to Fathom.jl default"
    end
end
export @default_theme!
_default_theme = @load_preference("default_theme", default = "fathom()")
function default_theme()
    try
        eval(Meta.parse(_default_theme))
    catch e
        @error "Could not load theme. Reverting to Fathom.jl default"
        return fathom()
    end
end

"""
    demofigure()

Produce a figure showcasing the current theme.
"""
function demofigure()
    Random.seed!(32)
    f = TwelvePanel()
    gs = subdivide(f, 4, 3)

    ncolors = length(Fathom.colororder)

    # * Lines
    ax = Axis(
        gs[1][1, 1], title = "Measurements", xlabel = "Time (s)",
        ylabel = "Amplitude"
    )
    labels = [
        L"\alpha",
        L"\beta",
        L"\gamma",
        L"\delta",
        L"\epsilon",
        L"\zeta",
        L"\eta",
        L"\theta",
        L"\iota",
        L"\kappa",
    ]
    for i in 1:ncolors
        y = cumsum(randn(10)) .* (isodd(i) ? 1 : -1)
        lines!(y, label = labels[i])
        # scatter!(y, label = labels[i])
    end
    Legend(gs[1][1, 2], ax, "Legend", merge = true, nbanks = 2)

    # * Surface
    Axis3(gs[2][1, 1], viewmode = :stretch, zlabeloffset = 40, title = "Variable: σ ⤆ τ")
    s = Makie.surface!(
        0:0.05:10, 0:0.05:10, (x, y) -> sqrt(x * y) + sin(1.5x), alpha = 0.9,
        specular = 0.25,
    )
    Colorbar(gs[2][1, 2], s)

    # * Ziggurat
    ax = Makie.Axis(gs[3], title = "Ziggurat plots")
    tightlimits!(ax)
    for i in 1:3
        y = randn(200) .+ 2i
        ziggurat!(y)
    end

    # * Density
    ax = Axis(
        gs[4], title = "Density plots", xlabel = "Height (m)",
        ylabel = "Density"
    )
    for i in 1:ncolors
        y = randn(200) .+ 2i
        density!(y)
    end
    tightlimits!(ax, Bottom())
    Makie.xlims!(ax, -1, 15)

    # * Bars
    Axis(
        gs[5], title = "Stock performance", xticks = (1:ncolors, labels[1:ncolors]),
        xlabel = "Company",
        ylabel = "Gain (\$)"
    )
    for i in 1:ncolors
        data = randn(1)
        barplot!([i], data)
        rangebars!([i], data .- 0.2, data .+ 0.2)
    end

    # * Datashader
    ax = Makie.Axis(gs[6], title = "Strange attractor") # From the Makie docs for datashader
    function trajectory(fn, x0, y0, kargs...; n = 1000) #  kargs = a, b, c, d
        xy = zeros(Point2f, n + 1)
        xy[1] = Point2f(x0, y0)
        @inbounds for i in 1:n
            xy[i + 1] = fn(xy[i], kargs...)
        end
        return xy
    end
    Clifford((x, y), a, b, c, d) = Point2f(
        sin(a * y) + c * cos(a * x),
        sin(b * x) + d * cos(b * y)
    )
    arg = [0, 0, -1.7, 1.5, -0.5, 0.7]
    points = trajectory(Clifford, arg...; n = Int(5.0e5))
    datashader!(
        ax, points, async = false,
        colormap = cgrad(
            [:transparent, Fathom.light(bermejo), chernoe],
            [0, 0.4, 1]
        )
    )

    # * Violin plot
    ax = Makie.Axis(gs[7], title = "Violin plots", xlabel = "Group", ylabel = "Value")
    N = 200
    map(1:ncolors) do i
        y = randn(N) .+ randn()
        violin!(ax, fill(i, N), y)
    end

    # * Rainclouds
    ax = Axis(gs[8], title = "Raincloud plots", xlabel = "Group", ylabel = "Value")
    N = 50
    map(1:ncolors) do i
        y = randn(N) .+ randn()
        rainclouds!(ax, fill(i, N), y)
    end

    # * Boxplot
    ax = Axis(gs[9], title = "Boxplots", xlabel = "Group", ylabel = "Value")
    N = 200
    map(1:ncolors) do i
        y = randn(N) .^ 1 .+ randn() .+ (0.4 .* randn(N)) .^ 3
        boxplot!(ax, fill(i, N), y)
    end

    # * Polar histogram
    ax = PolarAxis(gs[10], title = "Polar histogram")
    x = randn(1000) .+ randn()
    polarhist!(ax, x, bins = 20, normalization = :pdf)

    # * Polar density
    ax = PolarAxis(gs[11], title = "Polar density")
    x = randn(1000) .+ randn()
    polardensity!(ax, x)

    # * Bandwidth
    ax = Axis(gs[12], title = "Bandwidth", xlabel = "Time (s)", ylabel = "Signal")
    x = range(0, 10, length = 200)
    y = @. sin(1.3 * x) + 0.15 * cos(4.7 * x)
    bandwidth!(ax, x, y; bandwidth = 0.5)

    return f
end

freeze!(anything) = ()
"""
    freeze!(ax::Union{Axis, Axis3, Figure}=current_figure())
Freeze the limits of an Axis or Axis3 object at their current values.

# Example
```julia
ax = Axis();
plot!(ax, -5:0.01:5, x->sinc(x))
freeze!(ax)
```
"""
function freeze!(ax::Union{Axis, Axis3})
    limits = ax.finallimits.val
    limits = zip(limits.origin, limits.origin .+ limits.widths)
    limits = collect(limits) |> Tuple
    ax.limits = limits
    return limits
end
freeze!(f::Figure) = freeze!.(f.content)
freeze!() = freeze!(current_figure())

"""
    tmpfile = clip(fig=Makie.current_figure(), fmt=:png; kwargs...)

Save the current figure to a temporary file and copy it to the clipboard. `kwargs` are passed to `Makie.save`.

# Example
```julia
f = plot(-5:0.01:5, x->sinc(x))
clip(f)
```
"""
function clip(fig = Makie.current_figure(), fmt = :png; kwargs...)
    freeze!(fig)
    tmp = tempname() * "." * string(fmt)
    Makie.save(tmp, fig; kwargs...)
    img = load(tmp)
    try
        clipboard_img(img)
    catch e
        @warn e
    end
    return tmp
end

function beep()
    return try
        sound(f) = [`play -q -n synth 0.1 sin $f`]
        @async [run.(sound(f)) for f in [500, 250, 450, 250, 425, 250, 500]]
        ()
    catch
    end
end

"""
    reverselegend!(l::Legend)

Reverse the order of the legend entries in an Axis object. This is useful when you want to
change the order of the legend entries without changing the order of the plotted data.
"""
function reverselegend!(l::Legend)
    entrygroups = l.entrygroups[]
    entrygroups[1][2] .= entrygroups[1][2] |> reverse
    return l.entrygroups[] = entrygroups
end

"""
    importall(module)

Return an array of expressions that can be used to import all names from a module.

# Example
```julia
importall(module) .|> eval
```
"""
function importall(mdl)
    mdl = eval(mdl)
    fullname = Symbol(mdl)
    exp = names(eval(mdl), all = true)
    return [:(import $fullname.$e) for e in exp]
end

"""
    scientific(x::Real, sigdigits=2)

Generate string representation of a number in scientific notation with a specified number of significant digits.

# Arguments
- `x::Real`: The number to be formatted.
- `sigdigits::Int=2`: The number of significant digits to display.

# Example
```julia
scientific(1/123.456, 2) # "8.10 × 10⁻³"
```
"""
function scientific(x::Real, sigdigits = 2)
    formatted = pyfmt(".$(sigdigits)e", x)
    formatted = replace(formatted, "e+0" => "e+")
    formatted = replace(formatted, "e-0" => "e-")
    formatted = replace(formatted, "e+" => "e")
    formatted = replace(formatted, "e" => " × 10^")

    # To display unicode superscripts for exponent
    exponent = split(formatted, "^")[2]
    if exponent[1] == '-'
        neg = "⁻"
        exponent = exponent[2:end]
    else
        neg = ""
    end

    unicode_exponent = join(
        ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'][parse(Int, digit) + 1]
            for digit in exponent
    )

    formatted = split(formatted, " ")[1] * " " * split(formatted, " ")[2] * " 10" * neg *
        unicode_exponent

    return s = replace(formatted, " × 10⁰" => "")
end

"""
    lscientific(x::Real, sigdigits=2)

Return a string representation of a number in scientific notation with a specified number of
significant digits. This is _not_ a LaTeXString.
See [`Lscientific`](@ref)

# Example
```julia
x = lscientific(1/123.456, 2) # "8.10 \\times 10^{-3}"
l = LaTeXString(x)
```
"""
function lscientific(x::Real, sigdigits = 2)
    formatted = pyfmt(".$(sigdigits)e", x)
    formatted = replace(formatted, "e+0" => "e+")
    formatted = replace(formatted, "e-0" => "e-")
    formatted = replace(formatted, "e+" => "e")

    s = replace(formatted, "e" => "\\times 10^{")
    s = s * "}"
    return s = replace(s, "\\times 10^{0}" => "")
end

"""
    lscientific(x::Real, sigdigits=2)

Return a string representation of a number in scientific notation with a specified number of
significant digits, as a LaTeXString.
See [`lscientific`](@ref)

# Example
```julia
x = Lscientific(1/123.456, 2) # L"8.10 \\times 10^{-3}"
```
"""
Lscientific(args...) = LaTeXString(lscientific(args...))

"""
    axiscolorbar(ax, args...; kwargs...)

Create a colorbar for the given `ax` axis. The `args` argument is passed to the `Colorbar` constructor, and the `kwargs` argument is passed to the `Colorbar` constructor as keyword arguments. The `position` argument specifies the position of the colorbar relative to the axis, and can be one of `:rt` (right-top), `:rb` (right-bottom), `:lt` (left-top), `:lb` (left-bottom). The default value is `:rt`.

# Example
```julia
f = Figure()
ax = Axis(f[1, 1])
x = -5:0.01:5
p = plot!(ax, x, x->sinc(x), color=1:length(x), colormap=sunset)
axiscolorbar(ax, p; label="Time (m)")
```
"""
function axiscolorbar(ax, args...; position = :rt, kwargs...)
    C = Colorbar(
        ax.parent, args...;
        bbox = ax.scene.px_area,
        Makie.legend_position_to_aligns(position)...,
        kwargs...
    )
    return if !isempty(C.label[])
        ax.alignmode = Mixed(right = 75)
    end
end

# * Tick formatting
"""
    percentageticks(x)
Return an array of strings representing the values in `x` as percentages, rounded to the
nearest integer.
"""
function percentageticks(x)
    return map(string ∘ Base.Fix1(round, Int), x .* 100)
end

"""
    terseticks(x::Real; sigdigits=5, kwargs...)
Return a string representation of a number `x` with trailing zeros removed, rounded to the
specified number of significant digits. The `kwargs` argument is passed to the `round`
function.
"""
function terseticks(x::Real; sigdigits = 5, kwargs...)
    y = round(x; sigdigits, kwargs...)
    s = string(y)
    if occursin(".", s)
        s = replace(s, r"(\.\d*?)0+$" => s"\1")
        s = replace(s, r"\.$" => "")
    end
    return s
end
terseticks(x; kwargs...) = terseticks.(x; kwargs...)
terseticks(; kwargs...) = x -> terseticks(x; kwargs...)

include("Theme.jl")
include("Polar.jl")
include("Prism.jl")
include("CovEllipse.jl")
include("Layouts.jl")
if haskey(ENV, "FATHOM_PATCHES")
    include(joinpath(@__DIR__, "Patches.jl"))
end

end
