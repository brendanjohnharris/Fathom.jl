using Makie
using LinearAlgebra
using Clustering

export prism, prismplot!

function _cluster(Σ²)
    issymmetric(Σ²) || error("Input covariance matrix is not symmetric")
    Dr = 1.0 .- abs.(Σ²)
    if !issymmetric(Dr)
        @warn "Correlation distance matrix is not symmetric, so not clustering"
    end
    Clustering.hclust(Dr; linkage = :average, branchorder = :optimal)
end

cluster(f, Σ²) = (c = _cluster(Σ²).order;
                  (collect(f)[c], Σ²[c]))
cluster(Σ²) = (c = _cluster(Σ²).order;
               Σ²[c, c])

to_xyz(c) = convert(Colors.XYZ, Makie.to_color(c))

"""
    prism(x, Y; [palette=[baikal, bermejo, qinghai], colormode=:top, verbose=false.])
Color a covariance matrix each element's contribution to each of the top `k` principal components, where `k` is the length of the supplied color palette (defaults to the number of principal component weights given).
Provide as positional arguments a vector `x` of N row names and an N×N covariance matrix `Y`.

# Keyword Arguments
- `palette`: a vector containing a color for each principal component.
- `colormode`: how to color the covariance matrix. `:raw` gives no coloring by principal components, `:top` is a combination of the top three PC colors (default) and `:all` is a combination of all PC colors, where PCN = :black if N > length(palette).
- `verbose`: whether to print the feature weights to the console
"""
function prism(Σ̂²;
               palette = [Fathom.baikal, Fathom.bermejo, Fathom.qinghai],
               colormode = :top,
               verbose = false)
    A = abs.(Σ̂²) ./ max(abs.(Σ̂²)...)
    N = min(length(palette), size(Σ̂², 1))
    if colormode == :raw # * Don't color by PC's
        H = abs.(Σ̂²)
    else
        λ = (eigvals ∘ Symmetric ∘ Array)(Σ̂²)
        λi = sortperm(abs.(λ), rev = true)
        λ = λ[λi]
        P = (eigvecs ∘ Symmetric ∘ Array)(Σ̂²)[:, λi] # Now sorted by decreasing eigenvalue norm
        vidxs = sortperm(abs.(P[:, 1]), rev = true)
        verbose &&
            isnothing(printstyled("Feature weights:\n", color = :red, bold = true)) &&
            display(vcat(hcat("Feature", ["PC$i" for i in 1:N]...),
                         hcat(f̂[vidxs], round.(P[vidxs, 1:N], sigdigits = 3))))
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
            p = fill(:black, size(P, 2))
            p[1:N] = palette[1:N]
            𝑓′ = to_xyz.(p)
            [𝑓′[i] = Σ̂′²[i, i] * 𝑓′[i] for i in 1:length(𝑓′)]
        end
        𝑓 = Vector{eltype(𝑓′)}(undef, size(P̂, 1))
        try # Load colors by PC weights
            𝑓 = P̂ * 𝑓′
        catch
            # Equivalent but slower
            @info "Iterating to load covariances"
            for ii in 1:length(𝑓)
                𝑓[ii] = sum([P̂[ii, jj] * 𝑓′[jj] for jj in 1:length(𝑓′)])
            end
        end

        H = Array{Colors.XYZA}(undef, size(Σ̂²))
        for (i, j) in Tuple.(CartesianIndices(H)) # Apply the correlations as transparencies
            J = (𝑓[i] + 𝑓[j]) / 2
            H[i, j] = Colors.XYZA(J.x, J.y, J.z, A[i, j])
        end
        H = convert.((Colors.RGBA,), H)
    end
end

function prismplot!(ax::Axis, H; kwargs...)
    ax.aspect = 1
    heatmap!(ax, H; kwargs...)
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
function prismplot!(f::Makie.GridPosition, args...;
                    colormap = seethrough(cgrad([baikal, baikal])),
                    limits, axis = (), title = nothing, colorbarlabel = nothing, kwargs...)
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
    prismplot!(f, g, H; limits, kwargs...)
end
function prismplot!(f::Makie.GridPosition, X::AbstractMatrix{<:Number}; kwargs...)
    H = prism(X)
    limits = extrema(abs.(X))
    prismplot!(f, H; limits, kwargs...)
end

# @recipe(PrismPlot, H) do scene
#     Theme(
#         colormap=:binary,
#         colorrange=nothing
#     )
# end

# function Makie.plot!(plot::PrismPlot)
#     H = plot.input_args |> first
#     plot.colormap = lift(cgrad, plot.attributes.colormap)
#     A = lift(H) do H
#         A = getproperty.(H, :alpha)[:]
#         return A ./ maximum(A)
#     end
#     plot.color = lift(A, plot.colormap) do A, c
#         return c[A]
#     end
#     # plot.calculated_colors = Makie.ColorMapping(
#     #     A[], plot.attributes.colormap, plot.attributes.colormap, colorrange,
#     #     get(plot, :colorscale, Observable(identity)),
#     #     get(plot, :alpha, Observable(1.0)),
#     #     get(plot, :highclip, Observable(automatic)),
#     #     get(plot, :lowclip, Observable(automatic)),
#     #     get(plot, :nan_color, Observable(RGBAf(0, 0, 0, 0))),
#     # )
#     heatmap!(plot, H)
#     plot
# end
