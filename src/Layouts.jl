export addlabels!, inset!, OnePanel, TwoPanel, FourPanel, SixPanel, NinePanel,
    TwelvePanel, subdivide
import Makie.GridLayoutBase.GridContent

# * A set of consistent figure layouts
function _panels(args...; height = 270, width = 720, scale = 1.0, kwargs...)
    f = Figure(args...; size = (width, height) .* scale, kwargs...)
    return f
end
function OnePanel(args...; kwargs...)
    f = _panels(args...; height = 270, width = 360, kwargs...)
    return f
end
function TwoPanel(args...; kwargs...)
    f = _panels(args...; height = 270, width = 720, kwargs...)
    return f
end
function FourPanel(args...; kwargs...)
    f = _panels(args...; height = 540, width = 720, kwargs...)
    return f
end
function SixPanel(args...; kwargs...)
    f = _panels(args...; height = 810, width = 720, kwargs...)
    return f
end
function NinePanel(args...; kwargs...)
    f = _panels(args...; height = 810, width = 1080, kwargs...)
    return f
end
function TwelvePanel(args...; kwargs...)
    f = _panels(args...; height = 1080, width = 1080, kwargs...)
    return f
end

struct SubdivideArray{T, N, A <: AbstractArray{T, N}} <: AbstractArray{T, N}
    parent::A
end

# Define array interface
Base.size(A::SubdivideArray) = size(A.parent)
Base.IndexStyle(::Type{<:SubdivideArray}) = IndexLinear()

# Cartesian indexing - works normally
Base.getindex(A::SubdivideArray, i::Int, j::Int) = A.parent[i, j]
Base.setindex!(A::SubdivideArray, v, i::Int, j::Int) = (A.parent[i, j] = v)

# Linear indexing - row-major order
function Base.getindex(A::SubdivideArray, i::Int)
    nrows, ncols = size(A)
    row = div(i - 1, ncols) + 1
    col = mod(i - 1, ncols) + 1
    return A.parent[row, col]
end

function Base.setindex!(A::SubdivideArray, v, i::Int)
    nrows, ncols = size(A)
    row = div(i - 1, ncols) + 1
    col = mod(i - 1, ncols) + 1
    return A.parent[row, col] = v
end

"""
    subdivide(f, nrows::Int, ncols::Int)::Matrix{GridPosition}

Subdivides a figure `f` into a grid with specified number of rows and columns.
Returns the corresponding grid positions

# Example
```julia
f = Figure()
gs = subdivide(f, 2, 2)
axs = Axis.(gs)
display(f)
```
"""
function subdivide(f, nrows::Int, ncols::Int)
    return grid = [f[i, j] for i in 1:nrows, j in 1:ncols] |> SubdivideArray
end
function subdivide(f, sz::Tuple{Int, Int})
    nrows, ncols = sz
    return subdivide(f, nrows, ncols)
end

"""
    _default_label(i::Integer)

Return the default panel label for the 1-based index `i` as a parenthesised, spreadsheet-style
letter sequence: `(a), (b), …, (z), (aa), (ab), …`. Unlike a plain `Char` shift this stays
alphabetic past 26 panels.
"""
function _default_label(i::Integer)
    s = ""
    while i > 0
        i, r = divrem(i - 1, 26)
        s = string(Char('a' + r), s)
    end
    return "($s)"
end

# Broadcast a scalar offset to all `n` labels, or validate that a per-label collection covers
# them (extra entries are ignored; too few is an error).
function _peroffset(x, n, name)
    x isa Union{Tuple, AbstractVector} || return fill(x, n)
    length(x) >= n && return x
    return error("`$name` has length $(length(x)), but $n labels need placing")
end

"""
    addlabels!(gridpositions, f::Figure, [text]; dx = 0, dy = 0, fontsize = 22, kwargs...)

Add labels to a provided grid layout. The labels are incremented in the linear order of the grid positions.

## Arguments
- `gridpositions`: An iterator of `GridPosition`s as produced by e.g. [`subdivide`](@ref).
- `f`: The figure associated with the grid positions (optional)
- `text`: Text to be displayed in the labels, as either an interator of strings or a
  function applied to the integer indices of the grid positions [optional; defaults to (a),
  (b), ...]
- `dx`, `dy`: The horizontal and vertical shift of each label from its panel's top-left
  corner, in points (positive `dx` rightward, positive `dy` upward; defaults `0`, `0`). A
  scalar applies to every label; a tuple/vector applies element-wise to labels `(a), (b), …`
  and must provide at least as many offsets as there are labels.
- `fontsize`: The label font size (default `22`).
- `kwargs`: Keyword arguments to be passed to the `Label` function.

## Examples
```julia
f = Figure()
gs = subdivide(f, 2, 2)
addlabels!(gs)
display(f)
```
"""
function addlabels!(
        gridpositions, f::Figure = first(gridpositions).layout.parent,
        text = nothing; dx = 0, dy = 0, fontsize = fathomfontsize() * 1.2, kwargs...
    )
    if !(eltype(gridpositions) <: GridPosition)
        throw(TypeError(:addlabels!, "Fathom", GridPosition, first(gridpositions)))
    end

    n = length(gridpositions)

    if isnothing(text)
        text = _default_label.(1:n)
    end
    if text isa Function
        text = text.(1:n)
    end
    if length(text) < n
        error("Number of labels does not match the number of valid blocks")
    end

    dxs = _peroffset(dx, n, "dx")
    dys = _peroffset(dy, n, "dy")

    for (i, l) in enumerate(gridpositions)
        lab = Label(
            l[1, 1, TopLeft()]; halign = :left, valign = :bottom,
            text = text[i], fontsize, kwargs...
        )
        # translate! rather than padding: Makie's Label padding resizes the box within an
        # auto-sizing protrusion (nonlinear in x, clamped in +y), so it can't translate.
        translate!(lab.blockscene, dxs[i], dys[i], 0)
    end
    return
end

"""
    inset!(pos; size = 0.55, halign = :right, valign = :top, decorate = false, kwargs...)

An `Axis` floating inside the grid position `pos` rather than filling it: it takes the
fraction `size` of the cell and is pinned to one corner, over a transparent background.
Decorations and spines are hidden unless `decorate = true`. Remaining `kwargs` are passed
to `Axis`. [`addlabels!`](@ref) skips insets, so the panel label stays with the main block.

## Examples
```julia
f = Figure()
ax = Axis(f[1, 1])
ax2 = inset!(f[1, 1]; size = 0.4)
```
"""
function inset!(
        pos; size = 0.55, halign = :right, valign = :top, decorate = false,
        backgroundcolor = :transparent, kwargs...
    )
    ax = Axis(
        pos; width = Relative(size), height = Relative(size), halign, valign,
        backgroundcolor, kwargs...
    )
    if !decorate
        hidedecorations!(ax)
        hidespines!(ax)
    end
    return ax
end

# Whether a block floats inside its cell rather than filling it, as an [`inset!`](@ref)
# does: an explicit size *and* an off-centre alignment. Panels pinned to a common size
# (`width`/`height` with the default centred alignment) are not insets.
function _isinset(block)
    sized = !isnothing(block.width[]) || !isnothing(block.height[])
    return sized && (block.halign[] !== :center || block.valign[] !== :center)
end

# Collect `block => (row, col)` for every allowed block, accumulating absolute grid
# positions across nested layouts in a single top-down descent.
function _labeltargets(
        gl::GridLayout, allowed, roff = 0, coff = 0,
        acc = Pair{Any, Tuple{Int, Int}}[]
    )
    for gc in gl.content
        r = roff + gc.span.rows.start - 1
        c = coff + gc.span.cols.start - 1
        block = gc.content
        if block isa GridLayout
            _labeltargets(block, allowed, r, c, acc)  # descend, carrying the offset
        elseif any(block isa T for T in allowed) && !_isinset(block)
            push!(acc, block => (r, c))
        end
    end
    return acc
end

"""
    addlabels!(f::Figure, [text]; dims=2, allowedblocks = [Axis, Axis3, PolarAxis], kwargs...)

Add labels to a provided grid layout, automatically searching for blocks to label.

## Arguments
- `f`: The figure to add labels to.
- `text`: Text to be displayed in the labels, as either an interator of strings or a
  function applied to the integer indices of the grid positions [optional; defaults to (a),
  (b), ...]
- `dims`: The order in which labels are incremented; `1` increments down each column first
  (column-major), `2` increments along each row first (row-major; default).
- `allowedblocks`: The types of blocks to consider for labelling (optional; defaults to `[Axis,
  Axis3, PolarAxis]`). Nested `GridLayout`s are always recursed into. Insets (see
  [`inset!`](@ref)) are skipped, so a cell is labelled once regardless of what floats in it.
- `kwargs`: Keyword arguments to be passed to the `Label` function.

## Examples
```julia
f = Fathom.demofigure()
addlabels!(f)
display(f)
```
See also: [`addlabels!`](@ref)
"""
function addlabels!(
        f::Figure, text = nothing;
        dims = 2,
        allowedblocks = [Axis, Axis3, PolarAxis], kwargs...
    )
    targets = _labeltargets(f.layout, allowedblocks)
    by = dims == 2 ? t -> (t[2][1], t[2][2]) : t -> (t[2][2], t[2][1])  # row- vs column-major
    sort!(targets; by)
    gridpositions = map(targets) do (block, _)
        b = block.layoutobservables.gridcontent[]
        b.parent[b.span.rows, b.span.cols]
    end
    return addlabels!(gridpositions, f, text; kwargs...)
end
