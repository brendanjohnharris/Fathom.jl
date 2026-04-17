using Fathom, Test, CairoMakie
import CairoMakie.RGB
using CairoMakie.Colors: Oklab

oklab_l(c) = 100 * convert(Oklab, convert(RGB, c)).l

base_colors = sort(collect(pairs(Fathom.BASE_COLORS)); by = p -> oklab_l(p[2]), rev = true)
dark_colors = sort(collect(pairs(Fathom.DARK_COLORS)); by = p -> oklab_l(p[2]), rev = true)
light_colors = sort(collect(pairs(Fathom.LIGHT_COLORS)); by = p -> oklab_l(p[2]),
                    rev = true)
                    
lighter_colors = sort(collect(pairs(Fathom.LIGHTER_COLORS)); by = p -> oklab_l(p[2]),
                      rev = true)
darker_colors = sort(collect(pairs(Fathom.DARKER_COLORS)); by = p -> oklab_l(p[2]),
                     rev = true)
pelagic_colors = sort(collect(pairs(Fathom.PELAGIC_COLORS)); by = p -> oklab_l(p[2]),
                      rev = true)

grouped_colors = [
    ("Base colors", base_colors),
    ("Dark variants", dark_colors),
    ("Darker variants", darker_colors),
    ("Light variants", light_colors),
    ("Lighter variants", lighter_colors),
    ("Pelagic colors", pelagic_colors)
]

ncols = maximum(length(group[2]) for group in grouped_colors)
nrows = length(grouped_colors)
row_height = 2.0
row_gap = 0.95
total_height = nrows * row_height + (nrows - 1) * row_gap

f = Figure(size = (120 * ncols, round(Int, 200 * nrows + 40)))
ax = Axis(f[1, 1],
          title = "Fathom colors vs Oklab grayscale (a = b = 0)",
          limits = ((-1.2, ncols), (0, total_height + 0.4)))
hidedecorations!(ax)
hidespines!(ax)

for (row_idx, (group_name, colorset)) in enumerate(grouped_colors)
    y0 = total_height - row_idx * row_height - (row_idx - 1) * row_gap

    text!(ax, -1.1, y0 + 1.0, text = group_name,
          align = (:left, :center), fontsize = 15, color = :gray20)

    for (col_idx, (name, c)) in enumerate(colorset)
        oc = convert(Oklab, convert(RGB, c))
        l = 100 * oc.l
        gray = convert(RGB, Oklab(oc.l, 0.0, 0.0))

        x0 = col_idx - 1
        poly!(ax, Rect2f(x0, y0 + 1.0, 1.0, 1.0), color = c, strokecolor = :transparent)
        poly!(ax, Rect2f(x0, y0, 1.0, 1.0), color = gray, strokecolor = :transparent)

        ltxt = "L=$(round(l, digits = 1))"
        txtcolor = l > 55 ? :black : :white
        text!(ax, x0 + 0.5, y0 + 0.5, text = ltxt, color = txtcolor,
              align = (:center, :center), fontsize = 11)
        text!(ax, x0 + 0.5, y0 + 2.08, text = String(name),
              align = (:center, :bottom), fontsize = 10)
    end
end

@test_nowarn save("./swatches.svg", f)
