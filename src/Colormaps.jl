oklch(c) = c |> values |> collect .|> Oklch
oklch(c::Colorant) = Oklch(c)
oklab(c) = c |> values |> collect .|> Oklab
oklab(c::Colorant) = Oklab(c)
lchuv(c) = c |> values |> collect .|> LCHuv
lchuv(c::Colorant) = LCHuv(c)

# pelagic_stops = map(PELAGIC_COLORS |> reverse) do c
#     oklch(c).l
# end |> values
pelagic_stops = [0, 0.25, 0.5, 1.0]
pelagic_stops = pelagic_stops .- minimum(pelagic_stops)
pelagic_stops = pelagic_stops ./ maximum(pelagic_stops)
const pelagic = cgrad(reverse(PELAGIC_COLORS) |> oklch, pelagic_stops) |> reverse

const cyclic = cgrad(
    [
        chernoe,
        bermejo,
        playa,
        baikal,
        chernoe,
    ] |> oklch,
    [0, 0.25, 0.5, 0.75, 1]
)

const lightsunset = cgrad(
    [
        darken(bermejo, 0.4),
        bermejo,
        playa,
        baikal,
        darken(baikal, 0.4),
    ] |> oklch, [0, 0.2, 0.5, 0.8, 1]
)

const darksunset = cgrad(
    [
        lighten(bermejo, 0.3),
        bermejo,
        chernoe,
        baikal,
        lighten(baikal, 0.3),
    ] |> oklch, [0, 0.2, 0.5, 0.8, 1]
)

const binarysunset = cgrad(
    [
        chernoe,
        darken(bermejo, 0.075),
        ianthina,
        baikal,
        playa,
    ] |> oklch,
    [0, 0.25, 0.5, 0.7, 1]
)

const sunset = cgrad(
    [
        bermejo,
        ianthina,
        baikal,
    ] |> lchuv, [0, 0.65, 1]
)

const sunrise = cgrad(
    [
        bermejo,
        ianthina,
        baikal,
        qinghai,
        seohae,
    ] |> oklch,
    [0, 0.3, 0.5, 0.75, 1]
)
# const sunrise = cgrad([bermejo,
#                           seohae,
#                           qinghai,
#                           baikal] |> oklch,
#                       [0, 0.3, 0.65, 1])

const cyclicsunrise = cgrad(
    [
        seohae,
        bermejo,
        ianthina,
        baikal,
        qinghai,
        seohae,
    ] |> oklch,
    [0, 0.2, 0.4, 0.6, 0.8, 1]
)

const fathom_colormaps = Dict(
    :sunset => sunset,
    :sunrise => sunrise,
    :cyclicsunrise => cyclicsunrise,
    :cyclic => cyclic,
    :lightsunset => lightsunset,
    :darksunset => darksunset,
    :binarysunset => binarysunset,
    :pelagic => pelagic
)

export sunset, sunrise,
    cyclic, cyclicsunrise,
    lightsunset, darksunset, binarysunset,
    pelagic
