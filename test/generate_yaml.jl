using Fathom, Test, YAML, CairoMakie

function tohex(c)
    ok = convert(Oklab{Float64}, c)
    rgb = convert(RGB{Float64}, ok)
    if !(0 <= rgb.r <= 1 && 0 <= rgb.g <= 1 && 0 <= rgb.b <= 1)
        lo, hi = 0.0, 1.0
        for _ in 1:20
            mid = (lo + hi) / 2
            test = Oklab{Float64}(ok.l, ok.a * mid, ok.b * mid)
            trgb = convert(RGB{Float64}, test)
            if 0 <= trgb.r <= 1 && 0 <= trgb.g <= 1 && 0 <= trgb.b <= 1
                lo = mid
            else
                hi = mid
            end
        end
        rgb = convert(RGB{Float64}, Oklab{Float64}(ok.l, ok.a * lo, ok.b * lo))
    end
    r = round(Int, rgb.r * 255)
    g = round(Int, rgb.g * 255)
    b = round(Int, rgb.b * 255)
    return uppercase(
        "#" * string(r, base = 16, pad = 2) *
            string(g, base = 16, pad = 2) *
            string(b, base = 16, pad = 2)
    )
end

data = Dict{String, Dict{String, String}}()
for (name, base) in pairs(Fathom.BASE_COLORS)
    data[String(name)] = Dict(
        "base" => tohex(base),
        "light" => tohex(Fathom.light(base)),
        "dark" => tohex(Fathom.dark(base)),
        "lighter" => tohex(Fathom.lighter(base)),
        "darker" => tohex(Fathom.darker(base))
    )
end
for (name, base) in pairs(Fathom.PELAGIC_COLORS)
    data[String(name)] = Dict(
        "base" => tohex(base),
        "light" => tohex(Fathom.light(base)),
        "dark" => tohex(Fathom.dark(base)),
        "lighter" => tohex(Fathom.lighter(base)),
        "darker" => tohex(Fathom.darker(base))
    )
end
data["playa"] = Dict(
    "base" => tohex(Fathom.playa),
    "light" => tohex(Fathom.light(Fathom.playa)),
    "dark" => tohex(Fathom.dark(Fathom.playa)),
    "lighter" => tohex(Fathom.lighter(Fathom.playa)),
    "darker" => tohex(Fathom.darker(Fathom.playa))
)

path = joinpath(@__DIR__, "colors.yaml")
YAML.write_file(path, data)
@test isfile(path)

loaded = YAML.load_file(path)
for (name, _) in pairs(Fathom.BASE_COLORS)
    key = String(name)
    @test haskey(loaded, key)
    @test haskey(loaded[key], "base")
    @test haskey(loaded[key], "light")
    @test haskey(loaded[key], "dark")
    @test haskey(loaded[key], "lighter")
    @test haskey(loaded[key], "darker")
end
for (name, _) in pairs(Fathom.PELAGIC_COLORS)
    key = String(name)
    @test haskey(loaded, key)
    @test haskey(loaded[key], "base")
    @test haskey(loaded[key], "light")
    @test haskey(loaded[key], "dark")
    @test haskey(loaded[key], "lighter")
    @test haskey(loaded[key], "darker")
end
@test haskey(loaded, "playa")
@test haskey(loaded["playa"], "base")
@test haskey(loaded["playa"], "light")
@test haskey(loaded["playa"], "dark")
@test haskey(loaded["playa"], "lighter")
@test haskey(loaded["playa"], "darker")
