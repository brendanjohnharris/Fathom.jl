using Makie
using Random
using LinearAlgebra

"""
    ellipsecov(a, b, ϕ = 0)

The covariance whose 1σ ellipse has semi-axis `a` at an angle `ϕ` from the x-axis and
semi-axis `b` across it; the inverse of drawing an ellipse with [`covellipse`](@ref), which
should then be passed `scale = 1`.

## Examples
```julia
covellipse!(ax, [0.0, 0.0], ellipsecov(3, 1, π / 4); scale = 1)
```
"""
function ellipsecov(a, b, ϕ = 0)
    R = [cos(ϕ) -sin(ϕ); sin(ϕ) cos(ϕ)]
    return R * Diagonal([a^2, b^2]) * R'
end
export ellipsecov

"""
    covellipse(μ, Σ²; kwargs...)

Plots an ellipse representing a multivariate normal distribution with mean
`μ` and covariance matrix `Σ²`.

## Key attributes:

`scale` = `2`: The scale factor for the ellipse size, in units of standard deviation.

`vertices` = `1000`: The number of vertices to use for the ellipse, or a list of angular
vertices.

`wobble_amp` = `0`: The amplitude of a hand-drawn wobble of the perimeter, as a fraction
of the radius (the root-mean-square perturbation over the perimeter). `0` draws an exact
ellipse.

`wobble_rate` = `3`: The roughness of the wobble, as the number of oscillations around the
perimeter. Low rates give a few broad lobes; high rates give a fine crinkle.

`wobble_seed` = `0`: The seed for the wobble, so the same outline is drawn on every redraw.
"""
@recipe CovEllipse (μ, Σ²) begin
    "Scale factor for the ellipse size, in units of standard deviation."
    scale = 2
    "Number of vertices to use for the ellipse, or a list of angular vertices"
    vertices = 1000
    "Amplitude of a hand-drawn wobble, as a fraction of the radius; 0 is an exact ellipse"
    wobble_amp = 0
    "Roughness of the wobble, as the number of oscillations around the perimeter"
    wobble_rate = 3
    "Seed for the wobble, so the same outline is drawn on every redraw"
    wobble_seed = 0
    get_drop_attrs(Poly, [])...
end

"""
    wobbleradii(θ, amp, rate, seed)

The radial modulation of a unit circle sampled at angles `θ`: harmonics in a narrow band
around `rate`, with random amplitudes and phases, scaled so the perturbation has
root-mean-square amplitude `amp`. Since these are harmonics of a full turn the modulation
is periodic, so a perturbed outline stays smooth and closed.
"""
function wobbleradii(θ, amp, rate, seed)
    iszero(amp) && return ones(length(θ))
    rng = Xoshiro(seed)
    k₀ = max(2, round(Int, rate))
    ρ = zeros(length(θ))
    for k in max(2, k₀ - 1):(k₀ + 1)
        ρ .+= randn(rng) .* cos.(k .* θ .+ 2π * rand(rng))
    end
    rms = sqrt(sum(abs2, ρ) / length(ρ))
    return 1 .+ (amp / max(rms, eps())) .* ρ
end

function Makie.plot!(plot::CovEllipse)
    map!(
        plot.attributes,
        [:μ, :Σ², :scale, :vertices, :wobble_amp, :wobble_rate, :wobble_seed], :x
    ) do μ, Σ², scale, vertices, wobble_amp, wobble_rate, wobble_seed
        if size(Σ², 1) != 2 || size(Σ², 2) != 2 || length(μ) != 2
            throw(
                ArgumentError(
                    "CovEllipse requires a 2×2 covariance and a length-2 mean; " *
                        "got size(Σ²)=$(size(Σ²)) and length(μ)=$(length(μ))"
                )
            )
        end
        θ = vertices isa Integer ? range(0, 2π; length = vertices) : vertices
        ρ = wobbleradii(θ, wobble_amp, wobble_rate, wobble_seed)
        A = sqrt(Σ²) * ([cos.(θ)'; sin.(θ)'] .* ρ') .* scale
        x = [Makie.Point2f(μ[1] + a[1], μ[2] + a[2]) for a in eachcol(A)]
        return x
    end

    poly!(plot, plot.attributes, plot.x)
    return plot
end

# Makie.convert_arguments(p::Type{<:CovEllipse}, Σ²::AbstractMatrix) = Makie.convert_arguments(p, zeros(size(Σ², 1)), Σ²)
