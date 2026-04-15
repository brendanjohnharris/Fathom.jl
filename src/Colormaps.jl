function perceived_lightness(c::AbstractRGB)
    # ? https://stackoverflow.com/questions/596216/formula-to-determine-perceived-brightness-of-rgb-color
    r, g, b = c.r, c.g, c.b
    lin(c) = c ≤ 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055)^2.4
    Y = 0.2126lin(r) + 0.7152lin(g) + 0.0722lin(b)
    return Y ≤ (216 / 24389) ? Y * (24389 / 27) : 116 * Y^(1 / 3) - 16
end
export perceived_lightness

function make_lightness_linear(cs; flat = false, tol = 0.001)
    ls = perceived_lightness.(RGB.(cs))
    if flat
        mb = [mean(ls), 0] # Constant brightness
    else
        mb = [ones(length(ls)) (1:length(ls))] \ ls
    end
    L = mb[1] .+ mb[2] * (1:length(ls)) |> collect
    map(enumerate(cs)) do (i, c)
        l = L[i]
        while abs(l - perceived_lightness(c)) > tol &&
            perceived_lightness(c) ∈ 0.1 .. 99.9
            if perceived_lightness(c) > l
                c = darken(c, tol)
            else
                c = brighten(c, tol)
            end
        end
        return c
    end
end
export make_lightness_linear

oklch(c) = c |> values |> collect .|> Oklch
oklch(c::Colorant) = Oklch(c)
oklab(c) = c |> values |> collect .|> Oklab
oklab(c::Colorant) = Oklab(c)
lchuv(c) = c |> values |> collect .|> LCHuv
lchuv(c::Colorant) = LCHuv(c)

pelagic_stops = map(PELAGIC_COLORS |> reverse) do c
    oklch(c).l
end |> values
pelagic_stops = pelagic_stops .- minimum(pelagic_stops)
pelagic_stops = pelagic_stops ./ maximum(pelagic_stops)
const pelagic = cgrad(reverse(PELAGIC_COLORS) |> oklch, pelagic_stops) |> reverse

const cyclic = cgrad([chernoe,
                         bermejo,
                         light(abyad),
                         baikal,
                         chernoe] |> oklch,
                     [0, 0.25, 0.5, 0.75, 1])

const lightsunset = cgrad([bermejo,
                              light(abyad),
                              baikal] |> oklch, [0, 0.5, 1])

const darksunset = cgrad([bermejo,
                             chernoe,
                             baikal] |> oklch, [0, 0.5, 1])

const binarysunset = cgrad([chernoe,
                               bermejo,
                               ianthina,
                               baikal,
                               light(abyad)] |> oklch,
                           [0, 0.25, 0.5, 0.7, 1])

const sunset = cgrad([bermejo,
                         ianthina,
                         baikal] |> lchuv, [0, 0.65, 1])

const sunrise = cgrad([bermejo,
                          seohae,
                          qinghai,
                          baikal] |> oklch,
                      [0.25, 0.4, 0.6, 0.75])

const cyclicsunrise = cgrad([
                                seohae,
                                bermejo,
                                ianthina,
                                baikal,
                                qinghai,
                                seohae
                            ] |> oklch,
                            [0, 0.2, 0.4, 0.6, 0.8, 1])

const fathom_colormaps = Dict(:sunset => sunset,
                              :sunrise => sunrise,
                              :cyclicsunrise => cyclicsunrise,
                              :cyclic => cyclic,
                              :lightsunset => lightsunset,
                              :darksunset => darksunset,
                              :binarysunset => binarysunset,
                              :pelagic => pelagic)

export sunset, sunrise,
       cyclic, cyclicsunrise,
       lightsunset, darksunset, binarysunset,
       pelagic
