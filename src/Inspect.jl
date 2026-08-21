export layouttree, layoutslack, layoutedges, layoutlabels, fitsize

# Layout introspection. A solved Makie layout already knows where everything is; these read it
# back so panel sizes can be chosen from measurements rather than from repeated renders.
#
# Three numbers on every block explain essentially every layout surprise:
#
#   reporteddimensions.inner   the size the block reports to its parent. `nothing` in a
#                   dimension means NON-DETERMINABLE: the block never names a size there, so its
#                   row or column absorbs the leftover space and the block is then fitted into
#                   whatever it got. Most "why did this stretch?" questions end here. Note this
#                   is NOT `autosize`, which stays `nothing` even for an axis given an explicit
#                   `width`/`height`; and an aspect-locked axis with a fixed height reports
#                   `(nothing, h)` --- it never names a width, so its column is non-determinable
#                   and the axis letterboxes inside it.
#   suggestedbbox   what the parent cell offered.
#   computedbbox    the box the block took. Smaller than the cell means it is centred (or
#                   aligned) in slack.
#
# Protrusions are the decoration margin (ticks, labels, titles) drawn OUTSIDE the block's box.
# The parent reserves room for them, which is why a panel with a long title sits lower than its
# neighbours even though their boxes match.

"""
    drawnbox(block)

The rectangle actually painted. For an `Axis` this is `scene.viewport`, which is NOT its
`computedbbox`: an axis with `aspect` set holds its shape by letterboxing inside the box the
layout gave it. The difference is invisible in the layout numbers alone and is a common source
of unexplained whitespace.
"""
drawnbox(b::Axis) = b.scene.viewport[]
drawnbox(b) = b.layoutobservables.computedbbox[]

_box(r) = round.(Int, (r.origin[1], r.origin[2], r.widths[1], r.widths[2]))

_fmt(::Nothing) = "—"
_fmt(x::Real) = string(round(Int, x))
_fmt(t::Tuple) = "(" * join(_fmt.(t), ",") * ")"

_sizestr(s::Auto) = s.trydetermine ? (s.ratio == 1 ? "auto" : "auto:$(s.ratio)") : "grow:$(s.ratio)"
_sizestr(s::Fixed) = "fix($(round(Int, s.x)))"
_sizestr(s::Relative) = "rel($(round(s.x; digits = 3)))"
_sizestr(s::Aspect) = "asp($(s.index),$(round(s.ratio; digits = 2)))"
_sizestr(v::AbstractVector) = "[" * join(_sizestr.(v), " ") * "]"

_gapstr(name, v) = isempty(v) ? "" : " $name=" * _sizestr(v)

_rng(r) = length(r) == 1 ? string(first(r)) : "$(first(r)):$(last(r))"
_spanstr(::Nothing) = ""
_spanstr(sp) = "[$(_rng(sp.rows)),$(_rng(sp.cols))] "

"""
    layoutslack(block) -> (cell, aspect, total)

Three `(dx, dy)` gaps in pixels. `cell` is offered-minus-taken: the block is smaller than its
cell, usually because a neighbour sharing that row or column is bigger. `aspect` is
taken-minus-drawn: the block letterboxes inside its own box to hold an aspect ratio. `total` is
the two together, which is the whitespace actually visible around the panel.
"""
function layoutslack(b::Makie.Block)
    lo = b.layoutobservables
    room, got, drew = lo.suggestedbbox[], lo.computedbbox[], drawnbox(b)
    d(a, c) = round.(Int, (a.widths[1] - c.widths[1], a.widths[2] - c.widths[2]))
    return (cell = d(room, got), aspect = d(got, drew), total = d(room, drew))
end

"""
    layouttree(f::Figure; io, minslack, maxdepth)
    layouttree(gl::GridLayout; ...)

Print the layout hierarchy: every nested `GridLayout` with its row and column size specs and
gaps, and every block with what it asked for, the box it got, the box it drew, and its
protrusions. Blocks with at least `minslack` px of slack in either direction are flagged, since
that is where a figure's whitespace comes from.

Sizes print as `auto` (sized to content), `grow:r` (takes a share of leftover space), `fix(n)`,
`rel(x)` or `asp(i,r)`. An `ask` of `—` marks a dimension the block will not pin down.

## Examples
```julia
f = Fathom.demofigure()
layouttree(f)
```
See also: [`layoutslack`](@ref), [`layoutedges`](@ref), [`fitsize`](@ref)
"""
layouttree(f::Figure; kwargs...) = layouttree(f.layout; kwargs...)

function layouttree(
        gl::GridLayout; io = stdout, depth = 0, span = nothing, minslack = 12,
        maxdepth = 8
    )
    depth > maxdepth && return nothing
    println(
        io, "  "^depth, _spanstr(span), "GridLayout $(gl.size[1])×$(gl.size[2])",
        "  rows=", _sizestr(gl.rowsizes), " cols=", _sizestr(gl.colsizes),
        _gapstr("rowgaps", gl.addedrowgaps), _gapstr("colgaps", gl.addedcolgaps)
    )
    for gc in gl.content
        layouttree(gc.content; io, depth = depth + 1, span = gc.span, minslack, maxdepth)
    end
    return nothing
end

function layouttree(
        b::Makie.Block; io = stdout, depth = 0, span = nothing, minslack = 12,
        maxdepth = 8
    )
    lo = b.layoutobservables
    p = lo.protrusions[]
    sl = layoutslack(b)
    drew = drawnbox(b)
    # `draw` is only printed when the block does not fill the box it was given, which for an
    # Axis means `aspect` is binding. Sub-pixel rounding is not a difference worth reporting.
    off = abs.(_box(drew) .- _box(lo.computedbbox[]))
    drawstr = maximum(off) <= 1 ? "" : " draw=" * _fmt(_box(drew))
    flag = any(abs.(sl.total) .>= minslack) ?
        "   << slack $(_fmt(sl.total)) = cell $(_fmt(sl.cell)) + aspect $(_fmt(sl.aspect))" : ""
    println(
        io, "  "^depth, _spanstr(span), nameof(typeof(b)),
        "  ask=", _fmt(lo.reporteddimensions[].inner), " got=", _fmt(_box(lo.computedbbox[])), drawstr,
        " prot=", _fmt((p.left, p.right, p.bottom, p.top)), flag
    )
    return nothing
end

layouttree(::Any; kwargs...) = nothing

"""
    layoutslack(f::Figure; io, n, skipinsets, blocktype)

Print the `n` blocks whose offered cell most exceeds what they drew, largest first: the direct
answer to "where is the whitespace". Insets (see [`inset!`](@ref)) float inside their cell by
design, so they are skipped unless `skipinsets = false`.

## Examples
```julia
f = Fathom.demofigure()
layoutslack(f)
```
See also: [`layouttree`](@ref)
"""
function layoutslack(
        f::Figure; io = stdout, n = 12, skipinsets = true, blocktype = Axis
    )
    rows = [
        (b, layoutslack(b)) for b in f.content
            if b isa blocktype && !(skipinsets && _isinset(b))
    ]
    sort!(rows; by = r -> -maximum(abs, r[2].total))
    println(io, "slack, largest first   (total = cell + aspect):")
    for (b, sl) in first(rows, n)
        println(
            io, "  ", rpad(string(nameof(typeof(b))), 6), rpad(_fmt(sl.total), 12),
            "= cell ", rpad(_fmt(sl.cell), 11), "+ aspect ", rpad(_fmt(sl.aspect), 11),
            "draw=", _fmt(_box(drawnbox(b)))
        )
    end
    return nothing
end

"""
    fitsize(f::Figure)

The figure size this layout wants, as `(width, height)`. A `nothing` marks a dimension the
layout will not pin down because something in it is non-determinable; that is also the case
`resize_to_layout!` cannot handle, and the dimension you must supply yourself.

Note that the layout's own bbox IS the scene, with any `Outside` padding applied inside it, so
the alignmode padding is already counted here --- do not add it again.

Passing the result to `Figure(size = ...)` is the one-shot way to stop a figure either clipping
its own content or floating in empty margin.

## Examples
```julia
f = Fathom.demofigure()
fitsize(f)
```
"""
function fitsize(f::Figure)
    a = f.layout.layoutobservables.autosize[]
    return map(x -> isnothing(x) ? nothing : round(Int, x), a)
end

"""
    layoutedges(f::Figure; dim, tol, io, blocktype)

Print the distinct left/right (`dim = 1`) or bottom/top (`dim = 2`) edges of every block, with
the blocks sharing each one. Panels that should line up but do not appear here as two edges a
few pixels apart, which is hard to see by eye and easy to see in this list.

## Examples
```julia
f = Fathom.demofigure()
layoutedges(f)          # vertical edges, and which axes share them
```
See also: [`layoutslack`](@ref)
"""
function layoutedges(f::Figure; dim = 1, tol = 2, io = stdout, blocktype = Axis)
    bs = filter(x -> x isa blocktype, f.content)
    marks = Dict{Int, Vector{Int}}()
    for (i, b) in enumerate(bs)
        r = drawnbox(b)
        for e in (r.origin[dim], r.origin[dim] + r.widths[dim])
            near = findfirst(k -> abs(k - e) <= tol, collect(keys(marks)))
            key = isnothing(near) ? round(Int, e) : collect(keys(marks))[near]
            push!(get!(marks, key, Int[]), i)
        end
    end
    println(io, dim == 1 ? "vertical edges (x):" : "horizontal edges (y):")
    for k in sort(collect(keys(marks)))
        println(io, "  ", lpad(k, 5), "  blocks ", sort(unique(marks[k])))
    end
    return nothing
end

"""
    layoutlabels(f::Figure; io, tol, blocktype)

Print each `Label`'s offset from the block it sits over, and flag the outliers.

`addlabels!` anchors a panel letter to its cell's `TopLeft()` corner, NOT to the block drawn in
that cell. When the block does not fill its cell --- an aspect-locked axis letterboxing, say ---
the letter stays pinned to the cell and drifts away from the panel it names. The offsets are
uniform in a healthy figure, so an outlier here is exactly that bug. `layoutslack` will not show
it: it reports on axes, and the thing that moved is a label.
"""
function layoutlabels(f::Figure; io = stdout, tol = 25)
    rows = Tuple{String, Tuple{Int, Int}}[]
    for l in filter(x -> x isa Label, f.content)
        b = _labelpartner(l)
        isnothing(b) && continue
        lb, nb = l.layoutobservables.computedbbox[], drawnbox(b)
        push!(rows, (l.text[], round.(Int, (nb.origin[1] - lb.origin[1], nb.origin[2] - lb.origin[2]))))
    end
    if isempty(rows)
        println(io, "no panel labels found (addlabels! not called?)")
        return nothing
    end
    dxs = sort([r[2][1] for r in rows])
    med = dxs[cld(length(dxs), 2)]
    println(io, "label offsets to the block they sit on (dx, dy); median dx = $med:")
    for (t, d) in rows
        println(io, "  ", rpad(t, 6), _fmt(d), abs(d[1] - med) > tol ? "   << detached" : "")
    end
    return nothing
end

"""
    _labelpartner(l::Label)

The block a `Label` was placed over. `addlabels!` puts the letter in a cell's `TopLeft()`
protrusion, which Makie wraps in its own 1x1 `GridLayout`, so the label's own grid content
points at that wrapper rather than at the panel. Walking up one level gives the real cell, and
the `Inner()` content of that cell is the block the letter names.
"""
function _labelpartner(l::Label)
    gc = l.layoutobservables.gridcontent[]
    isnothing(gc) && return nothing
    outer = gc.parent.layoutobservables.gridcontent[]   # the wrapper's own cell
    isnothing(outer) && return nothing
    for c in outer.parent.content
        c.side isa Makie.GridLayoutBase.Inner || continue
        c.span.rows.start == outer.span.rows.start || continue
        c.span.cols.start == outer.span.cols.start || continue
        c.content isa Makie.Block && return c.content
        # the cell may hold a nested layout; take its first block
        if c.content isa GridLayout
            for cc in c.content.content
                cc.content isa Makie.Block && return cc.content
            end
        end
    end
    return nothing
end
