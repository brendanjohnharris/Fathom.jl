# CairoMakie drawing for Fathom's `svgimage` recipe. librsvg paints the document directly onto
# CairoMakie's Cairo surface, so vector saves (.svg/.pdf) keep it vector; raster saves rasterise
# it at the surface resolution. This is the core of MakieTeX's SVGDocument, minus its pin to a
# specific Makie minor: only `project_position` and `screen.context` are touched here.
module FathomRsvgExt

import Fathom
import Fathom: SVGImage
import Makie
import Makie: Point2d
import CairoMakie
import CairoMakie: Cairo
import Rsvg

# Keep SVGImage as a drawing unit: `cairo_draw` flattens scenes to atomic leaves, so without
# this it would collect only the recipe's (invisible) child poly and never reach `draw_plot`.
CairoMakie.is_cairomakie_atomic_plot(plot::SVGImage) = true

function CairoMakie.draw_plot(
        scene::Makie.Scene, screen::CairoMakie.Screen, plot::SVGImage
    )
    plot.visible[] || return
    handle = Rsvg.handle_new_from_data(plot.svg[])
    dims = Rsvg.handle_get_dimensions(handle)
    if dims.width <= 0 || dims.height <= 0
        error("librsvg could not parse the SVG document (reported size $(dims.width) × $(dims.height))")
    end
    (x0, x1), (y0, y1) = plot.x[], plot.y[]
    model = plot.model[]
    space = plot.space[]
    tf = Makie.transform_func(plot)
    # Projected in Cairo's convention (y down, origin at the scene viewport's top left), so the
    # data rect's top-left corner is (x0, y1).
    tl = CairoMakie.project_position(scene, tf, space, Point2d(x0, y1), model)
    br = CairoMakie.project_position(scene, tf, space, Point2d(x1, y0), model)
    ctx = screen.context
    Cairo.save(ctx)
    Cairo.translate(ctx, tl[1], tl[2])
    Cairo.scale(ctx, (br[1] - tl[1]) / dims.width, (br[2] - tl[2]) / dims.height)
    Rsvg.handle_render_cairo(ctx, handle)
    Cairo.restore(ctx)
    return
end

end
