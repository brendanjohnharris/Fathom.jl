# ? Format recipe docstrings
using Makie.DocStringExtensions
import Makie: DocThemer, ATTRIBUTES, DocInstances, INSTANCES

import Makie: mixin_generic_plot_attributes, mixin_colormap_attributes,
    documented_attributes, attribute_names, DocumentedAttributes, automatic
import Makie.StatsBase

function get_attrs(P::Type{<:Plot})
    # Makie.attribute_default_expressions(P)
    return Makie.documented_attributes(P)
end
function drop_attrs(attrs::DocumentedAttributes, keys)
    attrs = deepcopy(attrs)
    map(collect(keys)) do key
        if haskey(attrs.d, key)
            delete!(attrs.d, key)
        end
    end
    return attrs
end
function get_drop_attrs(P::Type{<:Plot}, keys)
    attrs = get_attrs(P)
    return drop_attrs(attrs, keys)
end

"""
    ziggurat(x; kwargs...)

Plots a histogram with a transparent fill and a stepped outline.

## Key attributes:
`color` = `@inherit patchcolor`: Color of the interior fill.

`strokecolor` = `@inherit patchstrokecolor`: Color of the step outline.

`strokewidth` = `@inherit patchstrokewidth`: Width of the step outline.

`linestyle` = `nothing`: Line pattern of the step outline.

`fillalpha` = `0.5`: Transparency of the interior fill.

`filternan` = `true`: Whether to remove NaN values from the data before plotting.
"""
@recipe Ziggurat (x,) begin
    "Sets the color of the histogram fill."
    color = @inherit patchcolor

    "Sets the color of the histogram outline."
    strokecolor = @inherit patchstrokecolor
    "Sets the linewidth of the histogram outline."
    strokewidth = @inherit patchstrokewidth
    "Sets the line pattern of the histogram outline."
    linestyle = nothing
    "Controls whether the outline draws around the complete histogram (true) or just the top steps (false)."
    strokearound = false

    "Transparency of the histogram fill"
    fillalpha = 0.5

    "Whether to remove NaN values"
    filternan = true

    get_drop_attrs(Hist, [:cycle, :color, :strokecolor, :strokewidth])...
    get_drop_attrs(StepHist, [attribute_names(Hist)..., :linestyle])...
end

function Makie.plot!(plot::Ziggurat{<:Tuple{AbstractVector{<:Real}}})
    map!(plot.attributes, [:x, :filternan], :values) do v, filternan
        filternan ? filter(!isnan, v) : v
    end
    map!(plot.attributes, [:color, :fillalpha], :fillcoloralpha) do c, a
        Makie.to_color(isnothing(a) ? c : (c, a))
    end

    hist!(plot, plot.attributes, plot.values; color = plot.fillcoloralpha, strokewidth = 0)
    stephist!(
        plot, plot.attributes, plot.values; color = plot.strokecolor,
        linestyle = plot.linestyle, linewidth = plot.strokewidth,
        visible = map(!, plot.strokearound)
    )

    # Build a closed step path when strokearound is true. Compute the histogram the same way
    # `hist!` does (honouring `bins`, `normalization` and `weights`) so the outline traces
    # the bars rather than a differently-binned, unnormalised shape.
    map!(
        plot.attributes, [:values, :strokearound, :bins, :normalization, :weights],
        :linepoints
    ) do x, strokearound, bins, normalization, weights
        if !strokearound || isempty(x)
            return Point2f[]
        end
        edges = bins isa Int ? range(minimum(x), maximum(x), length = bins + 1) : bins
        w = weights === automatic ? () : (StatsBase.weights(weights),)
        h = StatsBase.fit(StatsBase.Histogram, x, w..., edges)
        h = StatsBase.normalize(h; mode = normalization)
        edges = h.edges[1]
        weights = h.weights
        ps = Point2f[]
        push!(ps, Point2f(first(edges), 0))
        for i in eachindex(weights)
            push!(ps, Point2f(edges[i], weights[i]))
            push!(ps, Point2f(edges[i + 1], weights[i]))
        end
        push!(ps, Point2f(last(edges), 0))
        push!(ps, Point2f(first(edges), 0))
        return ps
    end
    lines!(
        plot, plot.linepoints; color = plot.strokecolor,
        linestyle = plot.linestyle, linewidth = plot.strokewidth,
        visible = plot.strokearound
    )

    return plot
end

"""
    bandwidth(x, y; kwargs...)

Plots a band of a certain width about a center line.

## Key attributes:
`bandwidth` = `1`: Vertical width of the band in data space. Can be a vector of `length(x)`.

`direction` = `:x`: The direction of the band, either `:x` or `:y`.
"""
@recipe Bandwidth (x, y) begin
    "Sets the color of the bandwidth fill."
    color = @inherit patchcolor

    "Sets the color of the bandwidth outline."
    strokecolor = @inherit patchstrokecolor

    "Transparency of the bandwidth fill"
    fillalpha = 0.5

    "Vertical width of the band in data space"
    bandwidth = 1
    "The direction of the band"
    direction = :x

    get_drop_attrs(Band, [:color, :strokecolor, :direction])...
end
function Makie.plot!(
        plot::Bandwidth{
            <:Tuple{
                AbstractVector{<:Real},
                AbstractVector{<:Real},
            },
        }
    )
    map!(plot.attributes, [:color, :fillalpha], :fillcoloralpha) do c, a
        Makie.to_color(isnothing(a) ? c : (c, a))
    end
    map!(plot.attributes, [:x, :y, :bandwidth, :direction], [:xx, :yl, :yu]) do x, y, l, d
        if d === :y
            x, y = y, x
        end
        if eltype(l) <: Number
            yl = y .- (l / 2)
            yu = y .+ (l / 2)
        else
            yl = y .- (first(l) / 2)
            yu = y .+ (last(l) / 2)
        end
        return x, yl, yu
    end
    return band!(
        plot, plot.attributes, plot.attributes[:xx], plot.attributes[:yl],
        plot.attributes[:yu]; color = plot.fillcoloralpha,
        strokecolor = plot.strokecolor
    )
end

"Contents of the SVG document `svg`, given either as a file path or as the source itself."
readsvg(svg::AbstractString) = occursin("<svg", svg) ? String(svg) : read(svg, String)

"""
    svgsize(svg::AbstractString)

Intrinsic size of an SVG document, from its `viewBox` (or failing that, `width`/`height`)
attributes. Parsed textually so it needs no SVG library; used only for the default extents of
[`svgimage`](@ref), where a mis-parse costs the default aspect ratio, not the rendering.
"""
function svgsize(svg::AbstractString)
    vb = match(r"<svg[^>]*\sviewBox\s*=\s*[\"']([^\"']+)[\"']"i, svg)
    if !isnothing(vb)
        nums = tryparse.(Float64, split(strip(vb[1]), r"[\s,]+"))
        length(nums) == 4 && !any(isnothing, nums) && return (nums[3], nums[4])
    end
    w, h = map(("width", "height")) do attr
        m = match(Regex("<svg[^>]*\\s$(attr)\\s*=\\s*[\"']([0-9.eE+-]+)[a-z%]*[\"']", "i"), svg)
        isnothing(m) ? nothing : tryparse(Float64, m[1])
    end
    (isnothing(w) || isnothing(h)) && return (1.0, 1.0)
    return (w, h)
end

"""
    svgimage(svg; kwargs...)
    svgimage(x, y, svg; kwargs...)

Draws an SVG document as true vector graphics into the rectangle spanned by `x` and `y` in data
space (intervals, tuples, or vectors; by default `0 .. width` and `0 .. height` from the
document's intrinsic size, matching `image`). `svg` is a file path or the SVG source itself.
Set `aspect = DataAspect()` on the axis to display the document undistorted.

Drawing requires the `FathomRsvgExt` extension: load `Rsvg` alongside `CairoMakie`, and the
document is painted by librsvg directly onto the Cairo surface, so `.svg` and `.pdf` saves keep
it vector while `.png` rasterises it at the surface resolution (a miniature MakieTeX, without
its Makie version pin). Other backends draw nothing.

# Example
```julia
using CairoMakie, Rsvg
fig = Figure()
ax = Axis(fig[1, 1]; aspect = DataAspect())
hidedecorations!(ax)
svgimage!(ax, "logo.svg")
```
"""
@recipe SVGImage (x, y, svg) begin
    mixin_generic_plot_attributes()...
end

function Makie.convert_arguments(::Type{<:SVGImage}, svg::AbstractString)
    s = readsvg(svg)
    w, h = svgsize(s)
    return ((0.0, w), (0.0, h), s)
end
function Makie.convert_arguments(::Type{<:SVGImage}, x, y, svg::AbstractString)
    return (Float64.(extrema(x)), Float64.(extrema(y)), readsvg(svg))
end

function Makie.plot!(plot::SVGImage)
    # Invisible child so every backend sees an atomic to walk; the actual drawing is
    # CairoMakie-specific, in FathomRsvgExt.
    map!(plot.attributes, [:x, :y], :rectpoints) do x, y
        Point2d[(x[1], y[1]), (x[2], y[1]), (x[2], y[2]), (x[1], y[2])]
    end
    poly!(plot, plot.rectpoints; color = :transparent, strokewidth = 0, visible = false)
    if isnothing(Base.get_extension(Fathom, :FathomRsvgExt))
        @warn "svgimage draws nothing without the FathomRsvgExt extension: load `Rsvg` together with `CairoMakie`" maxlog = 1
    end
    return plot
end

function Makie.data_limits(plot::SVGImage)
    (x0, x1), (y0, y1) = plot.x[], plot.y[]
    return Rect3d(Point3d(x0, y0, 0), Vec3d(x1 - x0, y1 - y0, 0))
end
function Makie.boundingbox(plot::SVGImage, space::Symbol = :data)
    return Makie.apply_transform_and_model(plot, Makie.data_limits(plot))
end
