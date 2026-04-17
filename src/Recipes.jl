# ? Format recipe docstrings
using Makie.DocStringExtensions
import Makie: DocThemer, ATTRIBUTES, DocInstances, INSTANCES

import Makie: mixin_generic_plot_attributes, mixin_colormap_attributes,
              documented_attributes, attribute_names, DocumentedAttributes, automatic

function get_attrs(P::Type{<:Plot})
    # Makie.attribute_default_expressions(P)
    Makie.documented_attributes(P)
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

    hist!(plot, plot.attributes, plot.x; color = plot.fillcoloralpha, strokewidth = 0)
    stephist!(plot, plot.attributes, plot.x; color = plot.strokecolor,
              linestyle = plot.linestyle, linewidth = plot.strokewidth,
              visible = map(!, plot.strokearound))

    # Build a closed step path when strokearound is true
    map!(plot.attributes, [:x, :strokearound, :bins], :linepoints) do x, strokearound, bins
        if !strokearound || isempty(x)
            return Point2f[]
        end
        h = StatsBase.fit(StatsBase.Histogram, x; nbins = bins)
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
    lines!(plot, plot.linepoints; color = plot.strokecolor,
           linestyle = plot.linestyle, linewidth = plot.strokewidth,
           visible = plot.strokearound)

    plot
end

"""
    bandwidth(x, y; kwargs...)

Plots a band of a certain width about a center line.

## Key attributes:
`bandwidth` = `1`: Vertical width of the band in data space. Can be a vector of `length(x)`.

`direction` = `:x`: The direction of the band, either `:x` or `:y`.
"""
@recipe Bandwidth (x, y) begin
    cycle = :color

    "Vertical width of the band in data space"
    bandwidth = 1
    "The direction of the band"
    direction = :x

    get_drop_attrs(Band, [:cycle, :direction])...
end
function Makie.plot!(plot::Bandwidth{<:Tuple{AbstractVector{<:Real},
                                             AbstractVector{<:Real}}})
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
    band!(plot, plot.attributes, plot.attributes[:xx], plot.attributes[:yl],
          plot.attributes[:yu])
end
