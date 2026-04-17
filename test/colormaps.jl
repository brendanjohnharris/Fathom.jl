using Fathom
using Test
using CairoMakie
import CairoMakie: Oklab, Oklch

# Keep this simple: sample each continuous gradient and render two heatmap strips.
gradient_items = collect(pairs(Fathom.fathom_colormaps))
ncols = 2
nrows = 4
@test length(gradient_items) == ncols * nrows

nsteps = 256
sample_t = LinRange(0, 1, nsteps)
strip_rows = 14
fg = Figure(size = (600, 800))

for (i, (name, cmap)) in enumerate(gradient_items)
    r = fld(i - 1, ncols) + 1
    c = mod(i - 1, ncols) + 1
    ax = Axis(fg[r, c], title = String(name))

    # Sample the continuous gradient directly.
    grad_colors = cmap[sample_t]
    luminance_only = map(grad_colors) do col
        # Preserve perceptual lightness and remove chroma in Oklab space.
        oc = convert(Oklab{Float64}, col)
        Oklab{Float64}(oc.l, 0.0, 0.0)
    end |> cgrad

    vals = repeat(reshape(collect(1:nsteps), 1, nsteps), strip_rows, 1)
    vals_t = transpose(vals)
    heatmap!(ax, 1:nsteps, strip_rows .+ (1:strip_rows), vals_t,
             colormap = grad_colors, colorrange = (1, nsteps))
    heatmap!(ax, 1:nsteps, 1:strip_rows, vals_t,
             colormap = luminance_only, colorrange = (1, nsteps))

    hidedecorations!(ax)
    hidespines!(ax)
    xlims!(ax, 1, nsteps)
    ylims!(ax, 1, 2strip_rows)
end

rowgap!(fg.layout, 14)
colgap!(fg.layout, 16)
@test_nowarn save("./colormaps.png", fg)
