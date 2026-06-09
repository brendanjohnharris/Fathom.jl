using Makie
using LinearAlgebra

export prism, prismplot!

to_xyz(c) = convert(Colors.XYZ, Makie.to_color(c))

"""
    prism(Σ²; palette=[baikal, bermejo, qinghai], colormode=:top, verbose=false)

Color an N×N covariance (or correlation) matrix `Σ²` by each element's contribution to the top
`k` principal components, where `k = length(palette)`. Each entry's hue mixes the palette colors
in proportion to its squared PC loadings, and its opacity encodes the max-normalized covariance
magnitude. Returns an N×N matrix of `RGBA` colors (or `abs.(Σ²)` when `colormode = :raw`).

# Keyword Arguments
- `palette`: a vector with one color per principal component.
- `colormode`: how to color the matrix. `:raw` applies no PC coloring; `:top` (default) combines
  the top `length(palette)` PC colors; `:all` combines all PCs, coloring PCs beyond
  `length(palette)` black (which tends toward brown).
- `verbose`: whether to print the per-feature PC loadings to the console.

Row/column names are supplied separately to `prismplot!`.
"""
function prism(
        Σ̂²;
        palette = [Fathom.baikal, Fathom.bermejo, Fathom.qinghai],
        colormode = :top,
        verbose = false
    )
    colormode ∈ (:raw, :top, :all) ||
        error("Unknown colormode $(repr(colormode)); use :raw, :top, or :all")
    m = maximum(abs, Σ̂²)
    A = iszero(m) ? zeros(size(Σ̂²)) : abs.(Σ̂²) ./ m
    N = min(length(palette), size(Σ̂², 1))
    return if colormode == :raw # * Don't color by PC's
        H = abs.(Σ̂²)
    else
        λ = (eigvals ∘ Symmetric ∘ Array)(Σ̂²)
        λi = sortperm(abs.(λ), rev = true)
        λ = λ[λi]
        P = (eigvecs ∘ Symmetric ∘ Array)(Σ̂²)[:, λi] # Now sorted by decreasing eigenvalue norm
        vidxs = sortperm(abs.(P[:, 1]), rev = true)
        if verbose
            printstyled("Feature weights:\n", color = :red, bold = true)
            display(
                vcat(
                    hcat("Feature", ["PC$i" for i in 1:N]...),
                    hcat(vidxs, round.(P[vidxs, 1:N], sigdigits = 3))
                )
            )
        end
        P = abs.(P)
        if colormode === :top # * Color by the number of PC's given by the length of the color palette
            P = P[:, 1:N]
            P̂ = P .^ 2.0 ./ sum(P .^ 2.0, dims = 2)
            # Square the loadings, since they are added in quadrature. Maybe not a
            # completely faithful representation of the PC proportions, but should get the
            # job done.
            𝑓′ = to_xyz.(palette[1:N])
        elseif colormode === :all # * Color by all PC's. This can end up very brown
            Σ̂′² = Diagonal(abs.(λ))
            P̂ = P .^ 2.0 ./ sum(P .^ 2.0, dims = 2)
            p = Vector{Any}(fill(:black, size(P, 2)))
            p[1:N] = palette[1:N]
            𝑓′ = to_xyz.(p)
            [𝑓′[i] = Σ̂′²[i, i] * 𝑓′[i] for i in 1:length(𝑓′)]
        end
        𝑓 = P̂ * 𝑓′  # weighted combination of PC colors per feature

        # Mix each pair's colors; opacity encodes the normalized covariance magnitude
        H = map(CartesianIndices(Σ̂²)) do I
            i, j = Tuple(I)
            c = (𝑓[i] + 𝑓[j]) / 2
            convert(Colors.RGBA, Colors.XYZA(c.x, c.y, c.z, A[i, j]))
        end
    end
end

function prismplot!(ax::Axis, H; kwargs...)
    ax.aspect = 1
    return heatmap!(ax, H; kwargs...)
end
function prismplot!(ax::Axis, f, H; kwargs...)
    h = prismplot!(ax, H; kwargs...)
    n = H isa Observable ? size(H[], 1) : size(H, 1)
    xt = 1:n
    dt = length(xt) / (length(f))
    xt = xt[round.(Int, ceil(dt / 2):dt:end)]
    ax.xticks = (xt, string.(f))
    ax.xticklabelrotation = π / 2
    ax.yticks = (xt, string.(f))
    return h
end
function prismplot!(
        f::Makie.GridPosition, args...;
        colormap = seethrough(cgrad([baikal, baikal])),
        limits, axis = (), title = nothing, colorbarlabel = nothing, kwargs...
    )
    i = !isnothing(title)
    ax = Axis(f[i + 1, 1]; axis...)
    p = prismplot!(ax, args...; kwargs...)
    p.tellheight = true
    C = Colorbar(f[i + 1, 2]; limits, colormap = colormap, label = colorbarlabel)
    i && Label(f[1, :], title; halign = :center)
    # colsize!(f.layout, 1, Relative(0.8))
    # rowsize!(f.layout, 1, Aspect(2, 1))
    return f, ax
end

function prismplot!(f::Makie.GridPosition, g, X::AbstractMatrix{<:Number}; kwargs...)
    H = prism(X)
    limits = extrema(abs.(X))
    return prismplot!(f, g, H; limits, kwargs...)
end
function prismplot!(f::Makie.GridPosition, X::AbstractMatrix{<:Number}; kwargs...)
    H = prism(X)
    limits = extrema(abs.(X))
    return prismplot!(f, H; limits, kwargs...)
end
