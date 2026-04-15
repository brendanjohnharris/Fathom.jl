```@meta
CurrentModule = Fathom
```

```@setup Fathom
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Makie
using Fathom
```

# Fathom

Documentation for [Fathom](https://github.com/brendanjohnharris/Fathom.jl); a Makie theme and some utilities.


## Default theme
```@example Fathom
using CairoMakie
using Fathom
fathom() |> Makie.set_theme!
fig = Fathom.demofigure()
```

## Theme options
Any combination of the keywords below can be used to customise the theme.
### Dark
```@example Fathom
fathom(:dark, :transparent) |> Makie.set_theme!
fig = Fathom.demofigure()
```

### Transparent
```@example Fathom
fathom(:dark, :transparent) |> Makie.set_theme!
fig = Fathom.demofigure()
```

### Serif
```@example Fathom
fathom(:serif) |> Makie.set_theme!
fig = Fathom.demofigure()
```

### Physics
```@example Fathom
fathom(:physics) |> Makie.set_theme!
fig = Fathom.demofigure()
```