```@meta
CurrentModule = Fathom
```

```@setup Fathom
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Makie
using Fathom
using Statistics
import Makie.Linestyle
showable(::MIME"text/plain", ::AbstractVector{C}) where {C<:Colorant} = false
showable(::MIME"text/plain", ::PlotUtils.ContinuousColorGradient) = false
Makie.set_theme!(Fathom.fathom())
```


# Recipes

## [ziggurat](@ref)

```@shortdocs; canonical=false
ziggurat
```

```@example Fathom
x = randn(100)
ziggurat(x)
```

## [hill](@ref)

```@shortdocs; canonical=false
hill
```

```@example Fathom
x = randn(100)
hill(x)
```


## [bandwidth](@ref)

```@shortdocs; canonical=false
bandwidth
```

```@example Fathom
x = -π:0.1:π
bandwidth(x, sin.(x); bandwidth = sin.(x))
```

## [polarhist](@ref)

```@shortdocs; canonical=false
polarhist
```

```@example Fathom
polarhist(randn(1000) .* 2)
```

## [polardensity](@ref)

```@shortdocs; canonical=false
polardensity
```

```@example Fathom
polardensity(randn(1000) .* 2;
                 strokewidth = 5,
                 strokecolor = :angle,
                 strokecolormap = cyclic,
                 colormap=:viridis)
```

## [covellipse](@ref)

```@shortdocs; canonical=false
covellipse
```

```@example Fathom
xy = randn(100, 2) * [1 1; 0 0.5]
μ = mean(xy, dims = 1)
Σ² = cov(xy)

fig, ax, plt = covellipse(μ, Σ²)
scatter!(ax, xy)
fig
```

## prism

```@docs; canonical=false
prism
```

```@example Fathom
ys = sin.((0:0.001:(π * 1.5)) .+ (0.1:0.1:(2π))')
Σ² = cov(ys .+ randn(size(ys)) ./ 10; dims = 1)
H = prism(Σ²; palette = [baikal, bermejo]) # Generates the prism colors

f = Figure()
limits = (0, maximum(abs.(Σ²))) # You must set the limits manually
g, ax = prismplot!(f[1, 1], H; limits, colorbarlabel = "Covariance magnitude")
axislegend(ax,
            [
                PolyElement(color = (baikal, 0.7)),
                PolyElement(color = (bermejo, 0.7))
            ],
            ["PC 1", "PC 2"], position = :lt)
ax.xlabel = ax.ylabel = "Variable"
f
```
