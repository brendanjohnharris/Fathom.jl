```@meta
CurrentModule = Fathom
```

```@setup Fathom
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Makie
using Fathom
using Makie.IntervalSets
showable(::MIME"text/plain", ::AbstractVector{C}) where {C<:Colorant} = false
showable(::MIME"text/plain", ::PlotUtils.ContinuousColorGradient) = false
```

# Utilities

## addlabels!

Add labels to a provided grid layout, automatically searching for blocks to label.

```@example Fathom
f = Fathom.demofigure()
addlabels!(f)
display(f)
```

```@docs
addlabels!
```

## seethrough

Converts a color gradient into a transparent version.

```@example Fathom
C = cgrad(:viridis)
transparent_gradient = seethrough(C)
```

```@docs
seethrough
```

## scientific

Generate string representation of a number in scientific notation with a specified number of significant digits.

```@example Fathom
scientific(1/123.456, 3) # "8.10 × 10⁻³"
```

```@docs
scientific
```

There is also an `lscientific` method, which returns a LaTeX-style string:

```@example Fathom
lscientific(1/123.456, 3)
```

```@docs
lscientific
```

As well as `Lscientific`, which returns a `LaTeXString`:

```@example Fathom
Lscientific(1/123.456, 3)
```

```@docs
Lscientific
```


## tick formatting

Format tick labels to be as compact as possible:

```@example Fathom
lines(0:sqrt(2)/100:sqrt(2), sqrt; axis=(;xtickformat=terseticks))
```

```@docs
terseticks
```

Or, format proportion values as percentages:

```@example Fathom
lines(0:0.01:1, sqrt; axis=(;xtickformat=percentageticks))
```

```@docs
percentageticks
```


## reverse legend

Reverses the order of legend entries

```@docs
reverselegend!
```


## brighten and darken

Brighten a color by a given factor by blending it with white:

```@example Fathom
c = baikal
b = brighten(c, 0.2) # Brightens the color by 20%
cgrad([c, b], categorical=true) # hide
```

Or, darken a color by blending it with black:

```@example Fathom
c = baikal
d = darken(c, 0.2) # Darkens the color by 20%
cgrad([c, d], categorical=true) # hide
```

## widen

Slightly widens an interval by a fraction δ.

```@example Fathom
x = 0..1
Fathom.widen(x, 0.1)
```

```@docs
widen
```

## freeze!

Freezes the axis limits of a Makie figure.

```julia
fig, ax, plt = scatter(rand(10), rand(10))
freeze!(ax)
```

## clip

Copies a Makie figure to the clipboard.

```julia
fig, ax, plt = scatter(rand(10), rand(10))
clip(fig)
```

```@docs
clip
```

## importall

Imports all symbols from a module into the current scope. Use with caution.

```julia
importall(Fathom) .|> eval
```

```@docs
importall
```