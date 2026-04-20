using Fathom, Test, YAML, CairoMakie

tohex(c) = hex(c, :RRGGBB)

data = Dict{String, Dict{String, String}}()
for (name, base) in pairs(Fathom.BASE_COLORS)
    data[String(name)] = Dict("base" => tohex(base),
                              "light" => tohex(Fathom.light(base)),
                              "dark" => tohex(Fathom.dark(base)),
                              "lighter" => tohex(Fathom.lighter(base)),
                              "darker" => tohex(Fathom.darker(base)))
end
for (name, base) in pairs(Fathom.PELAGIC_COLORS)
    data[String(name)] = Dict("base" => tohex(base),
                              "light" => tohex(Fathom.light(base)),
                              "dark" => tohex(Fathom.dark(base)),
                              "lighter" => tohex(Fathom.lighter(base)),
                              "darker" => tohex(Fathom.darker(base)))
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
