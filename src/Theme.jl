"""
The Fathom colors: `baikal`, `bermejo`, `qinghai`, `seohae`, `ianthina`.
"""
const colors = cgrad(
    [baikal, bermejo, qinghai, seohae, ianthina, mesopelagic, abyad],
    categorical = true
)

const colororder = [c for c in colors]
const patchcolororder = [(c, 0.5) for c in colors]
palette = (;
    color = colororder,
    linecolor = colororder,
    patchcolor = patchcolororder,
    patchstrokecolor = colororder,
)

patchcycle = Cycle(
    [
        :color => :patchcolor,
        :strokecolor => :patchstrokecolor,
    ],
    covary = true
)

decoration_color = dark(abyad)
textcolor = :black
tickalign = 0.5 # Crosses the axis

function _fathom(; globalfonts = fathomfonts(), globalfontsize = fathomfontsize())
    return Theme(;
        colormap = pelagic,
        strokewidth = 5,
        strokecolor = baikal,
        strokevisible = true,
        font = :regular,
        fonts = globalfonts,
        palette,
        linewidth = 3,
        patchstrokewidth = 3,
        markersize = 15,
        fontsize = globalfontsize,
        linecap = :round,
        joinstyle = :round,
        Figure = (; size = (360, 270)),
        Axis = (;
            backgroundcolor = :white,
            topspinecolor = decoration_color,
            leftspinecolor = decoration_color,
            bottomspinecolor = decoration_color,
            rightspinecolor = decoration_color,
            leftspinevisible = true,
            rightspinevisible = true,
            bottomspinevisible = true,
            topspinevisible = true,
            xgridvisible = false,
            ygridvisible = false,
            xminorgridvisible = false,
            yminorgridvisible = false,
            xticksvisible = true,
            yticksvisible = true,
            xminorticksvisible = false,
            yminorticksvisible = false,
            xtickcolor = decoration_color,
            ytickcolor = decoration_color,
            xminortickcolor = decoration_color,
            yminortickcolor = decoration_color,
            xtickalign = tickalign,
            ytickalign = tickalign,
            xminortickalign = tickalign,
            yminortickalign = tickalign,
            spinewidth = 1,
            xticklabelcolor = textcolor,
            yticklabelcolor = textcolor,
            titlecolor = textcolor,
            xticksize = 4,
            yticksize = 4,
            xtickwidth = 1.5,
            ytickwidth = 1.5,
            xlabelpadding = 3,
            ylabelpadding = 3,
            palette,
            titlefont = :bold,
            titlesize = globalfontsize * 1.25,
            xlabelsize = globalfontsize * 1.25,
            ylabelsize = globalfontsize * 1.25,
        ),
        Legend = (;
            framevisible = false,
            padding = (1, 1, 1, 1),
            patchcolor = :transparent,
            titlefont = :bold,
        ),
        Axis3 = (;
            xspinesvisible = true,
            yspinesvisible = true,
            zspinesvisible = true,
            xgridvisible = false,
            ygridvisible = false,
            zgridvisible = false,
            yzpanelcolor = :white,
            xzpanelcolor = :white,
            xypanelcolor = :white,
            xticksvisible = true,
            yticksvisible = true,
            zticksvisible = true,
            xspinecolor_1 = decoration_color,
            xspinecolor_2 = decoration_color,
            xspinecolor_3 = decoration_color,
            xspinecolor_4 = decoration_color,
            yspinecolor_1 = decoration_color,
            yspinecolor_2 = decoration_color,
            yspinecolor_3 = decoration_color,
            yspinecolor_4 = decoration_color,
            zspinecolor_1 = decoration_color,
            zspinecolor_2 = decoration_color,
            zspinecolor_3 = decoration_color,
            zspinecolor_4 = decoration_color,
            xtickcolor = decoration_color,
            ytickcolor = decoration_color,
            ztickcolor = decoration_color,
            xtickalign = tickalign,
            ytickalign = tickalign,
            ztickalign = tickalign,
            titlefont = :bold,
            titlesize = globalfontsize * 1.25,
            xlabelsize = globalfontsize * 1.25,
            ylabelsize = globalfontsize * 1.25,
            zlabelsize = globalfontsize * 1.25,
            palette,
        ),
        PolarAxis = (;
            spinecolor = decoration_color,
            rtickcolor = decoration_color,
            thetatickcolor = decoration_color,
            rminortickcolor = decoration_color,
            thetaminortickcolor = decoration_color,
            rtickalign = tickalign,
            thetatickalign = tickalign,
            rminortickalign = tickalign,
            thetaminortickalign = tickalign,
            rticksvisible = true,
            thetaticksvisible = true,
            backgroundcolor = :transparent,
            clip = false,
            clipcolor = :transparent,
            palette,
        ),
        Colorbar = (;
            spinecolor = decoration_color,
            tickcolor = :white,
            tickalign = tickalign,
            ticklabelcolor = textcolor,
            spinewidth = 0,
            ticklabelpad = 5,
        ),
        Textbox = (;),
        Scatter = (;),
        Lines = (;
            linecap = :round,
            joinstyle = :round,
        ),
        Surface = (; specular = 0.25),
        Hist = (; cycle = patchcycle),
        RainClouds = (;
            clouds = hist, hist_bins = 10, jitter_width = 0.3,
            boxplot_width = 0.15,
            cloud_width = 0.3,
            markersize = 5,
            cycle = patchcycle,
        ),
        Density = (; cycle = patchcycle),
        Ziggurat = (; cycle = patchcycle),
        PolarHist = (; cycle = patchcycle),
        PolarDensity = (; cycle = patchcycle),
        Bandwidth = (; cycle = patchcycle),
        Violin = (; cycle = patchcycle, mediancolor = darker(abyad), show_median = true),
        BoxPlot = (;
            whiskercolor = darker(abyad), cycle = patchcycle,
            mediancolor = darker(abyad),
        ),
        BarPlot = (; cycle = patchcycle),
        Band = (; strokewidth = 0, cycle = patchcycle),
        Rangebars = (;
            color = darker(abyad),
            cycle = nothing,
        ),
        Label = (;
            valign = :top, halign = :left, font = :bold,
            fontsize = globalfontsize * 1.25,
        )
    )
end

"""
    fathom(options...; fonts=fathomfonts())

Return the default Fathom theme. The `options` argument can be used to modify the default values, by passing keyword arguments with the names of the attributes to be changed and their new values.

Some available options are:
- `:dark`: Use a dark background and light text.
- `:transparent`: Make the background transparent.
- `:minorgrid`: Show minor gridlines.
- `:serif`: Use a serif font.
- `:redblue`: Use a red-blue colormap.
- `:gray`: Use a grayscale colormap.
- `:physics`: Set a theme that resembles typical plots in physics journals.
"""
function fathom(options...; fonts = fathomfonts())
    if fonts isa String || fonts isa Symbol
        fonts = fathomfonts(Symbol(fonts))
    end
    if :serif ∈ options
        thm = _fathom(; globalfonts = fathomfonts(:serif))
    else
        thm = _fathom(; globalfonts = fonts)
    end
    options = collect(options)
    options = options[options .!= :serif]
    _fathom!.((thm,), Val.(options))
    return thm
end

function setall!(thm::Attributes, attribute, value)
    thm[attribute] = value
    for a in keys(thm)
        if thm[a] isa Attributes
            if value isa Attributes
                thm[a] = value
            else
                if haskey(thm[a], attribute)
                    thm[a][attribute] = value
                end
            end
        end
    end
    return
end

transparent = Makie.RGBA(0, 0, 0, 0)
function _fathom!(thm::Attributes, ::Val{:transparent})
    setall!(thm, :backgroundcolor, transparent)
    setall!(thm, :yzpanelcolor, transparent)
    setall!(thm, :xzpanelcolor, transparent)
    thm[:PolarAxis][:clip] = false
    thm[:PolarAxis][:clipcolor] = :transparent
    setall!(thm, :xypanelcolor, transparent)
    return
end
function _fathom!(thm::Attributes, ::Val{:minorgrid})
    setall!(thm, :xminorgridvisible, true)
    setall!(thm, :yminorgridvisible, true)
    setall!(thm, :zminorgridvisible, true)
    return
end
function _fathom!(thm::Attributes, ::Val{:dark})
    gridcolor = :gray38
    minorgridcolor = :gray51
    strokecolor = baikal
    textcolor = :white
    setall!(thm, :strokecolor, strokecolor)
    setall!(thm, :backgroundcolor, chernoe)
    setall!(thm, :textcolor, textcolor)
    setall!(thm, :xgridcolor, gridcolor)
    setall!(thm, :ygridcolor, gridcolor)
    setall!(thm, :zgridcolor, gridcolor)
    setall!(thm, :xtickcolor, gridcolor)
    setall!(thm, :ytickcolor, gridcolor)
    setall!(thm, :ztickcolor, gridcolor)
    setall!(thm, :xminorgridcolor, minorgridcolor)
    setall!(thm, :yminorgridcolor, minorgridcolor)
    setall!(thm, :zminorgridcolor, minorgridcolor)
    setall!(thm, :xticklabelcolor, textcolor)
    setall!(thm, :yticklabelcolor, textcolor)
    setall!(thm, :zticklabelcolor, textcolor)
    setall!(thm, :titlecolor, textcolor)
    setall!(thm, :yzpanelcolor, :transparent)
    setall!(thm, :xzpanelcolor, :transparent)
    setall!(thm, :xypanelcolor, :transparent)
    setall!(thm, :tickcolor, textcolor)
    setall!(thm, :ticklabelcolor, textcolor)
    setall!(thm, :spinecolor, gridcolor)
    thm[:Axis][:topspinecolor] = gridcolor
    thm[:Axis][:leftspinecolor] = gridcolor
    thm[:Axis][:bottomspinecolor] = gridcolor
    thm[:Axis][:rightspinecolor] = gridcolor
    thm[:Colorbar][:spinecolor] = gridcolor
    thm[:Axis3][:xspinesvisible] = true
    thm[:Axis3][:yspinesvisible] = true
    thm[:Axis3][:zspinesvisible] = true
    thm[:Axis3][:xticksvisible] = true
    thm[:Axis3][:yticksvisible] = true
    return thm[:Axis3][:zticksvisible] = true
end
function _fathom!(thm::Attributes, ::Val{:physics})
    setall!(thm, :topspinevisible, true)
    setall!(thm, :rightspinevisible, true)
    setall!(thm, :bottomspinevisible, true)
    setall!(thm, :leftspinevisible, true)
    setall!(thm, :xticksvisible, true)
    setall!(thm, :yticksvisible, true)
    setall!(thm, :zticksvisible, true)
    setall!(thm, :xtickalign, true)
    setall!(thm, :ytickalign, true)
    setall!(thm, :ztickalign, true)
    setall!(thm, :xminortickalign, true)
    setall!(thm, :yminortickalign, true)
    setall!(thm, :zminortickalign, true)

    setall!(thm, :xminorticksvisible, true)
    setall!(thm, :yminorticksvisible, true)
    setall!(thm, :zminorticksvisible, true)
    setall!(thm, :xminorticks, IntervalsBetween(5))
    setall!(thm, :yminorticks, IntervalsBetween(5))
    setall!(thm, :zminorticks, IntervalsBetween(5))

    setall!(thm, :topspinecolor, :black)
    setall!(thm, :rightspinecolor, :black)
    setall!(thm, :bottomspinecolor, :black)
    setall!(thm, :leftspinecolor, :black)

    setall!(thm, :xgridvisible, false)
    setall!(thm, :ygridvisible, false)
    setall!(thm, :zgridvisible, false)
    setall!(thm, :xminorgridvisible, false)
    setall!(thm, :yminorgridvisible, false)
    setall!(thm, :zminorgridvisible, false)

    setall!(thm, :xminorgridstyle, :dash)
    setall!(thm, :yminorgridstyle, :dash)
    setall!(thm, :zminorgridstyle, :dash)

    thm[:Axis3][:xgridvisible] = true
    thm[:Axis3][:ygridvisible] = true
    return thm[:Axis3][:zgridvisible] = true
end
