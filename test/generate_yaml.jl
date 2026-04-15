using Fathom, Test, YAML, CairoMakie

function tohex(c)
    rgb = convert(CairoMakie.Makie.RGB, c)
    r = round(Int, clamp(rgb.r, 0, 1) * 255)
    g = round(Int, clamp(rgb.g, 0, 1) * 255)
    b = round(Int, clamp(rgb.b, 0, 1) * 255)
    return uppercase(string("#", string(r, base = 16, pad = 2),
                            string(g, base = 16, pad = 2),
                            string(b, base = 16, pad = 2)))
end

data = Dict{String, Dict{String, String}}()
for (name, base) in pairs(Fathom.BASE_COLORS)
    data[String(name)] = Dict("base" => tohex(base),
                              "light" => tohex(Fathom.light(base)),
                              "dark" => tohex(Fathom.dark(base)))
end

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
end
