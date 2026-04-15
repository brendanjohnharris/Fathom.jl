# Based on https://github.com/savq/ColorUtils.jl
#
# `HSLuv` is defined as a proper `ColorTypes.Color{T,3}` subtype so it
# integrates with Colors.jl's conversion machinery (`convert(RGB, ::HSLuv)`,
# `convert(HSLuv, ::Colorant)`, alpha variants, promotion, etc.).

module HSLUV

using Colors
using Colors: ColorTypes
using Colors.ColorTypes: Color, Colorant, AbstractRGB, color_type

export HSLuv, hsluv, set_hsluv

"""
    HSLuv{T<:AbstractFloat} <: Color{T,3}

The HSLuv colorspace, a human-friendly alternative to HSL built on CIELUV.

# Fields and Ranges:
- `h`: Hue in *[0, 360]*
- `s`: Saturation in *[0, 100]*
- `l`: Lightness in *[0, 100]*
"""
struct HSLuv{T <: AbstractFloat} <: Color{T, 3}
    h::T
    s::T
    l::T
end

# Register an alpha variant (HSLuvA / AHSLuv) via the standard ColorTypes macro.
ColorTypes.@make_alpha(HSLuv, AHSLuv, HSLuvA, (h, s, l), (h, s, l), AbstractFloat, Float64)

ColorTypes.eltype_default(::Type{<:HSLuv}) = Float64

struct Line
    slope::Float64
    intercept::Float64
end

const REF_U = 0.19783000664283681
const REF_V = 0.468319994938791

const KAPPA = (29 / 3)^3
const EPSILON = (6 / 29)^3
const ACHROMA_EPS = 1e-8
const LIGHTNESS_EDGE_EPS = 1e-7

# Linear sRGB from XYZ (D65)
const RGB_FROM_XYZ = [3.240969941904521 -1.537383177570093 -0.498610760293
                      -0.969243636280870 1.875967501507720 0.041555057407175
                      0.055630079696993 -0.203976958888970 1.056971514242878]

distance_from_origin(line::Line) = abs(line.intercept) / sqrt(line.slope^2 + 1)
function length_of_ray_until_intersect(theta, line::Line)
    line.intercept / (sin(theta) - line.slope * cos(theta))
end

luvcoord(l, u, v) = (l = l, u = u, v = v)
lchcoord(l, c, h) = (l = l, c = c, h = h)

function get_bounds(l::Float64)
    result = Vector{Line}(undef, 6)
    sub1 = (l + 16)^3 / 1560896
    sub2 = sub1 > EPSILON ? sub1 : l / KAPPA

    i = 0
    for c in 1:3, t in 0:1
        m = @view RGB_FROM_XYZ[c, :]
        top1 = (284517 * m[1] - 94839 * m[3]) * sub2
        top2 = (838422 * m[3] + 769860 * m[2] + 731718 * m[1]) * l * sub2 - 769860 * t * l
        bottom = (632260 * m[3] - 126452 * m[2]) * sub2 + 126452 * t
        result[i += 1] = Line(top1 / bottom, top2 / bottom)
    end

    result
end

max_chroma(l::Float64) = minimum(distance_from_origin, get_bounds(l))

function max_chroma(l::Float64, h::Float64)
    hrad = deg2rad(h)
    minimum(get_bounds(l)) do bound
        len = length_of_ray_until_intersect(hrad, bound)
        len >= 0 ? len : Inf
    end
end

function luv_from_xyz(xyz::XYZ)
    x, y, z = Float64(xyz.x), Float64(xyz.y), Float64(xyz.z)
    l = y <= EPSILON ? y * KAPPA : 116 * y^(1 / 3) - 16

    if l == 0
        return luvcoord(0.0, 0.0, 0.0)
    end

    divider = x + 15 * y + 3 * z
    if divider == 0
        return luvcoord(l, 0.0, 0.0)
    end

    up = 4 * x / divider
    vp = 9 * y / divider
    u = 13 * l * (up - REF_U)
    v = 13 * l * (vp - REF_V)
    luvcoord(l, u, v)
end

function xyz_from_luv(luv)
    l, u, v = luv.l, luv.u, luv.v
    if l == 0
        return XYZ(0.0, 0.0, 0.0)
    end

    y = l <= 8 ? l / KAPPA : ((l + 16) / 116)^3
    up = u / (13 * l) + REF_U
    vp = v / (13 * l) + REF_V
    x = (y * 9 * up) / (4 * vp)
    z = y * (12 - 3 * up - 20 * vp) / (4 * vp)
    XYZ(x, y, z)
end

function lch_from_luv(luv)
    l, u, v = luv.l, luv.u, luv.v
    c = sqrt(u * u + v * v)
    h = if c < ACHROMA_EPS
        0.0
    else
        hh = rad2deg(atan(v, u))
        hh < 0 ? hh + 360 : hh
    end
    lchcoord(l, c, h)
end

function luv_from_lch(lch)
    hrad = deg2rad(lch.h)
    luvcoord(lch.l, cos(hrad) * lch.c, sin(hrad) * lch.c)
end

function lch_from_hsluv(c::HSLuv)
    h, s, l = Float64(c.h), Float64(c.s), Float64(c.l)
    if l > 100 - LIGHTNESS_EDGE_EPS
        return lchcoord(100.0, 0.0, h)
    elseif l < ACHROMA_EPS
        return lchcoord(0.0, 0.0, h)
    end
    chroma = max_chroma(l, h) / 100 * s
    lchcoord(l, chroma, h)
end

function hsluv_from_lch(lch)
    l, c, h = lch.l, lch.c, lch.h
    if l > 100 - LIGHTNESS_EDGE_EPS
        return HSLuv{Float64}(h, 0.0, 100.0)
    elseif l < ACHROMA_EPS
        return HSLuv{Float64}(h, 0.0, 0.0)
    end
    sat = c / max_chroma(l, h) * 100
    HSLuv{Float64}(h, sat, l)
end

xyz_from_hsluv(c::HSLuv) = xyz_from_luv(luv_from_lch(lch_from_hsluv(c)))
hsluv_from_xyz(xyz::XYZ) = hsluv_from_lch(lch_from_luv(luv_from_xyz(xyz)))

# Hook into the Colors.jl `cnvt` machinery. `convert(C, c)` in ColorTypes
# eventually dispatches to `Colors.cnvt(Cdest, csrc)` for cross-space conversion.
function Colors.cnvt(::Type{HSLuv{T}}, c::Colorant) where {T}
    xyz = convert(XYZ{Float64}, c)
    nt = hsluv_from_xyz(xyz)
    HSLuv{T}(T(nt.h), T(nt.s), T(nt.l))
end

# Route transparent colors through their opaque base color to avoid
# ambiguity with Colors.jl's generic TransparentColor conversion methods.
function Colors.cnvt(::Type{HSLuv{T}}, c::ColorTypes.TransparentColor) where {T}
    c0 = convert(color_type(typeof(c)), c)
    Colors.cnvt(HSLuv{T}, c0)
end

function Colors.cnvt(::Type{XYZ{T}}, c::HSLuv) where {T}
    xyz = xyz_from_hsluv(c)
    XYZ{T}(T(xyz.x), T(xyz.y), T(xyz.z))
end

# Route HSLuv --> AbstractRGB through XYZ. Without this, Colors.jl's
# `cnvt(::Type{CV}, ::Color) where CV<:AbstractRGB` catch-all raises an error.
function Colors.cnvt(::Type{CV}, c::HSLuv) where {CV <: AbstractRGB}
    Colors.cnvt(CV, Colors.cnvt(XYZ{eltype(c)}, c))
end

# Entry points needed because ColorTypes' `_convert` only forwards to `cnvt`
# when source and destination are unrelated color spaces (not both RGB etc.).
# For `convert(HSLuv, rgb)` with unparameterised `HSLuv` we need a route that
# picks the default element type.
Base.convert(::Type{HSLuv}, c::Colorant) = Colors.cnvt(HSLuv{Float64}, c)

"""
    hsluv(c)

Convert any `Colorant` to `HSLuv{Float64}`.
"""
hsluv(c::Colorant) = convert(HSLuv{Float64}, c)

"""
    set_hsluv(colors; h = nothing, s = nothing, l = nothing, outtype = RGB)

Warp each input color to the variant that has the requested HSLuv luminance `L`,
preserving hue and saturation by default. Any keyword among `h`, `s`, and `l`
that is supplied is fixed to that value for all colors. The output order matches
the input order.
"""
function set_hsluv(colors::AbstractVector{<:Colorant};
                   h::Union{Nothing, Real} = nothing,
                   s::Union{Nothing, Real} = nothing,
                   l::Union{Nothing, Real} = nothing,
                   outtype::Type = RGB)
    h_target = isnothing(h) ? nothing : mod(Float64(h), 360.0)
    s_target = isnothing(s) ? nothing : clamp(Float64(s), 0.0, 100.0)
    l_target = isnothing(l) ? nothing : clamp(Float64(l), 0.0, 100.0)

    map(colors) do c
        hc = hsluv(c)
        hh = isnothing(h_target) ? hc.h : h_target
        ss = isnothing(s_target) ? hc.s : s_target
        ll = isnothing(l_target) ? hc.l : l_target
        convert(outtype, HSLuv{Float64}(hh, ss, ll))
    end
end
set_hsluv(c::Colorant; kwargs...) = set_hsluv([c]; kwargs...) |> only

end
