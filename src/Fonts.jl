fathomfontsize() = 14

const FONT_DIR = joinpath(@__DIR__, "..", "fonts")

const serifbase = joinpath(FONT_DIR, "SourceSans3")
const stixbase = joinpath(FONT_DIR, "STIXTwoText")
const mathbase = joinpath(FONT_DIR, "STIXTwoMath")

# * Bundled Source Sans 3 font
const sans = joinpath(FONT_DIR, "SourceSans3-Regular.ttf")


function fathomfonts(font = :sans)
    return if font === :sans

        Makie.MathTeXEngine.set_texfont_family!(;
            regular = joinpath(serifbase, "SourceSans3-Regular.ttf"),
            bold = joinpath(serifbase, "SourceSans3-Bold.ttf"),
            italic = joinpath(serifbase, "SourceSans3-Italic.ttf"),
            bolditalic = joinpath(serifbase, "SourceSans3-BoldItalic.ttf"),
            medium = joinpath(serifbase, "SourceSans3-Medium.ttf"),
            mediumitalic = joinpath(serifbase, "SourceSans3-MediumItalic.ttf"),
            semibold = joinpath(serifbase, "SourceSans3-SemiBold.ttf"),
            semibolditalic = joinpath(serifbase, "SourceSans3-SemiBoldItalic.ttf"),
            math = joinpath(mathbase, "STIXTwoMath-Regular.ttf") # Math stays stix
        )

        Attributes(
            :black => joinpath(serifbase, "SourceSans3-Black.ttf"),
            :blackitalic => joinpath(serifbase, "SourceSans3-BlackItalic.ttf"),
            :bold => joinpath(serifbase, "SourceSans3-Bold.ttf"),
            :bolditalic => joinpath(serifbase, "SourceSans3-BoldItalic.ttf"),
            :extrabold => joinpath(serifbase, "SourceSans3-ExtraBold.ttf"),
            :extrabolditalic => joinpath(serifbase, "SourceSans3-ExtraBoldItalic.ttf"),
            :extralight => joinpath(serifbase, "SourceSans3-ExtraLight.ttf"),
            :extralightitalic => joinpath(serifbase, "SourceSans3-ExtraLightItalic.ttf"),
            :italic => joinpath(serifbase, "SourceSans3-Italic.ttf"),
            :light => joinpath(serifbase, "SourceSans3-Light.ttf"),
            :lightitalic => joinpath(serifbase, "SourceSans3-LightItalic.ttf"),
            :medium => joinpath(serifbase, "SourceSans3-Medium.ttf"),
            :mediumitalic => joinpath(serifbase, "SourceSans3-MediumItalic.ttf"),
            :regular => joinpath(serifbase, "SourceSans3-Regular.ttf"),
            :semibold => joinpath(serifbase, "SourceSans3-SemiBold.ttf"),
            :semibolditalic => joinpath(serifbase, "SourceSans3-SemiBoldItalic.ttf")
        )


    elseif font === :serif

        Makie.MathTeXEngine.set_texfont_family!(;
            regular = joinpath(stixbase, "STIXTwoText-Regular.ttf"),
            bold = joinpath(stixbase, "STIXTwoText-Bold.ttf"),
            italic = joinpath(stixbase, "STIXTwoText-Italic.ttf"),
            bolditalic = joinpath(stixbase, "STIXTwoText-BoldItalic.ttf"),
            medium = joinpath(stixbase, "STIXTwoText-Medium.ttf"),
            mediumitalic = joinpath(stixbase, "STIXTwoText-MediumItalic.ttf"),
            semibold = joinpath(stixbase, "STIXTwoText-SemiBold.ttf"),
            semibolditalic = joinpath(stixbase, "STIXTwoText-SemiBoldItalic.ttf"),
            math = joinpath(mathbase, "STIXTwoMath-Regular.ttf")
        )


        Attributes(
            :regular => joinpath(stixbase, "STIXTwoText-Regular.ttf"),
            :bold => joinpath(stixbase, "STIXTwoText-Bold.ttf"),
            :italic => joinpath(stixbase, "STIXTwoText-Italic.ttf"),
            :bolditalic => joinpath(stixbase, "STIXTwoText-BoldItalic.ttf"),
            :medium => joinpath(stixbase, "STIXTwoText-Medium.ttf"),
            :mediumitalic => joinpath(stixbase, "STIXTwoText-MediumItalic.ttf"),
            :semibold => joinpath(stixbase, "STIXTwoText-SemiBold.ttf"),
            :semibolditalic => joinpath(stixbase, "STIXTwoText-SemiBoldItalic.ttf")
        )

    else
        font
    end
end
