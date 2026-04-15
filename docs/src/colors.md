```@meta
CurrentModule = Fathom
```

```@setup Fathom
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Makie
using Fathom
showable(::MIME"text/plain", ::AbstractVector{C}) where {C<:Colorant} = false
showable(::MIME"text/plain", ::PlotUtils.ContinuousColorGradient) = false
```

# Colors

The Fathom colors are `baikal`, `bermejo`, `qinghai`, `seohae`, `ianthina`.

```@example Fathom
Fathom.colors
```

# Colormaps

## Sunrise

```@example Fathom
sunrise # hide
```

## Cyclic Sunrise

```@example Fathom
cyclicsunrise # hide
```

## Sunset

```@example Fathom
sunset # hide
```

## Dark Sunset

```@example Fathom
darksunset # hide
```

## Light Sunset

```@example Fathom
lightsunset # hide
```

## Binary Sunset

```@example Fathom
binarysunset # hide
```

## Cyclic

```@example Fathom
cyclic # hide
```

## Pelagic

```@example Fathom
pelagic # hide
```