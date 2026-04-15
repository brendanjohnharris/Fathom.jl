# const GRADIENT_LUMINANCE = 60
const BASE_LIGHT_OFFSET = 3
const LIGHT_SHIFT = 0.2
const DARK_SHIFT = 0.3
const LIGHT_DESATURATE = 0.4
const DARK_SATURATE = 0.1

function set_oklab(c::Colorant;
                   l::Union{Nothing, Real} = nothing,
                   a::Union{Nothing, Real} = nothing,
                   b::Union{Nothing, Real} = nothing,
                   outtype::Type = RGB)
    oc = convert(Oklab{Float64}, c)
    ll = isnothing(l) ? oc.l : clamp(Float64(l), 0.0, 100.0) / 100.0
    aa = isnothing(a) ? oc.a : Float64(a)
    bb = isnothing(b) ? oc.b : Float64(b)
    convert(outtype, Oklab{Float64}(ll, aa, bb))
end

function set_oklab(colors::AbstractVector{<:Colorant}; kwargs...)
    map(c -> set_oklab(c; kwargs...), colors)
end

"""
    light(c)

Return the light pastel variant of a color `c`, using
[`LIGHT_SHIFT`](@ref) in Oklab lightness and
[`LIGHT_DESATURATE`](@ref) chroma reduction.
"""
light(c) = lighten(c, LIGHT_SHIFT, LIGHT_DESATURATE)

"""
    dark(c)

Return the dark variant of a color `c`, darkened by [`DARK_SHIFT`](@ref)
in Oklab lightness with a mild chroma boost [`DARK_SATURATE`](@ref).
"""
dark(c) = darken(c, DARK_SHIFT, DARK_SATURATE)

const cornflowerblue = colorant"#6495ED"
const baikal = set_oklab(cornflowerblue; l = 63 .+ BASE_LIGHT_OFFSET) # Baikal sea, beautiful clear blue; the blue eye of siberia
export baikal

const crimson = colorant"#DC143C"
const bermejo = set_oklab(crimson; l = 53.0 .+ BASE_LIGHT_OFFSET) # Mar Bermejo (Vermilion sea, Gulf of California; spanish)
export bermejo

const cucumber = colorant"#77ab58"
const qinghai = set_oklab(cucumber; l = 68 .+ BASE_LIGHT_OFFSET) # Qinghai sea; blue or green/jade (qing; Mandarin)
export qinghai

const californian = colorant"#EF9901"
const seohae = set_oklab(californian; l = 78 .+ BASE_LIGHT_OFFSET) # Yellow sea; Korean West sea (seohae)
export seohae

const juliapurple = colorant"#9558b2"
const ianthina = set_oklab(juliapurple; l = 58 .+ BASE_LIGHT_OFFSET) # Purple sea snail (Janthina)
export ianthina

const greyseas = colorant"#cccccc" # White [sea] (the mediterranean; Arabic, al-Baḥr al-Abyaḍ)
const abyad = set_oklab(greyseas; l = 73 .+ BASE_LIGHT_OFFSET)
export abyad

const chernoe = colorant"#282C34" # Black sea (chernoe more); Russian
export chernoe

const BASE_COLORS = (; baikal, bermejo, qinghai, seohae, ianthina, abyad, chernoe)
const LIGHT_COLORS = map(light, BASE_COLORS)
const DARK_COLORS = map(dark, BASE_COLORS)

const epipelagic = colorant"#FA9F42"
const mesopelagic = colorant"#007878"
const bathypelagic = colorant"#023653"
const abyssopelagic = colorant"#280137"
const PELAGIC_COLORS = (; epipelagic, mesopelagic, bathypelagic, abyssopelagic)
const DARK_PELAGIC = map(dark, PELAGIC_COLORS)
const LIGHT_PELAGIC = map(light, PELAGIC_COLORS)

export epipelagic, mesopelagic, bathypelagic, abyssopelagic
