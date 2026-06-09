using Makie

"""
    covellipse(μ, Σ²; kwargs...)

Plots an ellipse representing a multivariate normal distribution with mean
`μ` and covariance matrix `Σ²`.

## Key attributes:

`scale` = `2`: The scale factor for the ellipse size, in units of standard deviation.

`vertices` = `1000`: The number of vertices to use for the ellipse, or a list of angular
vertices.
"""
@recipe CovEllipse (μ, Σ²) begin
    "Scale factor for the ellipse size, in units of standard deviation."
    scale = 2
    "Number of vertices to use for the ellipse, or a list of angular vertices"
    vertices = 1000
    get_drop_attrs(Poly, [])...
end

function Makie.plot!(plot::CovEllipse)
    map!(plot.attributes, [:μ, :Σ², :scale, :vertices], :x) do μ, Σ², scale, vertices
        if size(Σ², 1) != 2 || size(Σ², 2) != 2 || length(μ) != 2
            throw(
                ArgumentError(
                    "CovEllipse requires a 2×2 covariance and a length-2 mean; " *
                        "got size(Σ²)=$(size(Σ²)) and length(μ)=$(length(μ))"
                )
            )
        end
        θ = vertices isa Integer ? range(0, 2π; length = vertices) : vertices
        A = sqrt(Σ²) * [cos.(θ)'; sin.(θ)'] .* scale
        x = [Makie.Point2f(μ[1] + a[1], μ[2] + a[2]) for a in eachcol(A)]
        return x
    end

    poly!(plot, plot.attributes, plot.x)
    return plot
end

# Makie.convert_arguments(p::Type{<:CovEllipse}, Σ²::AbstractMatrix) = Makie.convert_arguments(p, zeros(size(Σ², 1)), Σ²)
