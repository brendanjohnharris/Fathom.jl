# Fathom.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://brendanjohnharris.github.io/Fathom.jl/dev/)
[![Build Status](https://github.com/brendanjohnharris/Fathom.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/brendanjohnharris/Fathom.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/brendanjohnharris/Fathom.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/brendanjohnharris/Fathom.jl)
[![code style: runic](https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9A%BE%E1%9B%81%E1%9A%B2-black)](https://github.com/fredrikekre/Runic.jl)

A Makie theme and some utilities.
# Usage
```Julia
using CairoMakie
using Fathom
fathom() |> Makie.set_theme!
fig = Fathom.demofigure()
```
![demo](test/demos/demo.png)

## Theme options
Any combination of the keywords below can be used to customise the theme.
### Dark
```Julia
fathom(:dark, :transparent) |> Makie.set_theme!
fig = Fathom.demofigure()
```
![demo](test/demos/dark.png)

### Transparent
```Julia
fathom(:dark, :transparent) |> Makie.set_theme!
fig = Fathom.demofigure()
```
![demo](test/demos/transparent.png)

### Serif
```Julia
fathom(:serif) |> Makie.set_theme!
fig = Fathom.demofigure()
```
![demo](test/demos/serif.png)

### Physics
```Julia
fathom(:physics) |> Makie.set_theme!
fig = Fathom.demofigure()
```
![demo](test/demos/physics.png)

# Utilities

### addlabels!

Add labels to a provided grid layout, automatically searching for blocks to label.

```julia
f = Fathom.demofigure()
addlabels!(f)
display(f)
```

### seethrough

Converts a color gradient into a transparent version.

```julia
C = cgrad(:viridis)
transparent_gradient = seethrough(C)
```

### scientific

Generate string representation of a number in scientific notation with a specified number of significant digits.

```julia
scientific(1/123.456, 3) # "8.10 × 10⁻³"
```

There is also an `lscientific` method, which returns a LaTeX string:
```julia
lscientific(1/123.456, 3) # "8.10 \\times 10^{-3}"
```

### brighten and darken

Brighten a color by a given factor by blending it with white:

```julia
brighten(baikal, 0.2) # Brightens the color by 20%
```

Or, darken a color by blending it with black:
```julia
darken(baikal, 0.2) # Darkens the color by 20%
```

### widen

Slightly widens an interval by a fraction δ.

```julia
x = (0.0, 1.0)
wider_interval = Fathom.widen(x, 0.1)
```

### freeze!

Freezes the axis limits of a Makie figure.
```julia
fig, ax, plt = scatter(rand(10), rand(10))
freeze!(ax)
```

### clip

Copies a Makie figure to the clipboard.
```julia
fig, ax, plt = scatter(rand(10), rand(10))
clip(fig)
```

### importall

Imports all symbols from a module into the current scope. Use with caution.
```julia
importall(Fathom) .|> eval
```

# Colors
The theme is based on the colors `[baikal, bermejo, qinghai, seohae, ianthina]`:

![palette](test/palette.svg)

It also provides the following colormaps:
#### sunrise
![sunrise](test/colormaps/sunrise.svg)
#### cyclicsunrise
![cyclicsunrise](test/colormaps/cyclicsunrise.svg)
#### sunset
![sunset](test/colormaps/sunset.svg)
#### darksunset
![darksunset](test/colormaps/darksunset.svg)
#### lightsunset
![lightsunset](test/colormaps/lightsunset.svg)
#### binarysunset
![binarysunset](test/colormaps/binarysunset.svg)
#### cyclic
![cyclic](test/colormaps/cyclic.svg)
#### pelagic
![pelagic](test/colormaps/pelagic.svg)

# Recipes
The following recipes are exported:

- `polarhist`
- `polardensity`
- `covellipse`
- `prism`
- `ziggurat`
- `hill`
- `bandwidth`

Details and examples can be found in the [recipes docs](https://brendanjohnharris.github.io/Fathom.jl/dev/recipes/).
