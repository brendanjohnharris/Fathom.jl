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

# Layouts

Reproducible figure sizes designed for A4 portrait documents.

## Subdivide

```@docs
subdivide
```

## Panels

### OnePanel

```@example Fathom
f = OnePanel()
gs = subdivide(f, 1, 1)
addlabels!(gs)
f
```

### TwoPanel

```@example Fathom
f = TwoPanel()
gs = subdivide(f, 1, 2)
addlabels!(gs)
f
```

### FourPanel

```@example Fathom
f = FourPanel()
gs = subdivide(f, 2, 2)
addlabels!(gs)
f
```

### SixPanel

```@example Fathom
f = SixPanel()
gs = subdivide(f, 3, 2)
addlabels!(gs)
f
```
