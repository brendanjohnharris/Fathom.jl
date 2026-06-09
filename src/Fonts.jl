fathomfontsize() = 14

const FONT_DIR = joinpath(@__DIR__, "..", "fonts")

const sansbase = joinpath(FONT_DIR, "SourceSans3")
const stixbase = joinpath(FONT_DIR, "STIXTwoText")
const mathbase = joinpath(FONT_DIR, "STIXTwoMath")


function fathomfonts(font = :sans)
    return if font === :sans

        Makie.MathTeXEngine.set_texfont_family!(;
            regular = joinpath(sansbase, "SourceSans3-Regular.ttf"),
            bold = joinpath(sansbase, "SourceSans3-Bold.ttf"),
            italic = joinpath(sansbase, "SourceSans3-Italic.ttf"),
            bolditalic = joinpath(sansbase, "SourceSans3-BoldItalic.ttf"),
            medium = joinpath(sansbase, "SourceSans3-Medium.ttf"),
            mediumitalic = joinpath(sansbase, "SourceSans3-MediumItalic.ttf"),
            semibold = joinpath(sansbase, "SourceSans3-SemiBold.ttf"),
            semibolditalic = joinpath(sansbase, "SourceSans3-SemiBoldItalic.ttf"),
            math = joinpath(mathbase, "STIXTwoMath-Regular.ttf") # Math stays stix
        )

        Attributes(
            :black => joinpath(sansbase, "SourceSans3-Black.ttf"),
            :blackitalic => joinpath(sansbase, "SourceSans3-BlackItalic.ttf"),
            :bold => joinpath(sansbase, "SourceSans3-Bold.ttf"),
            :bolditalic => joinpath(sansbase, "SourceSans3-BoldItalic.ttf"),
            :extrabold => joinpath(sansbase, "SourceSans3-ExtraBold.ttf"),
            :extrabolditalic => joinpath(sansbase, "SourceSans3-ExtraBoldItalic.ttf"),
            :extralight => joinpath(sansbase, "SourceSans3-ExtraLight.ttf"),
            :extralightitalic => joinpath(sansbase, "SourceSans3-ExtraLightItalic.ttf"),
            :italic => joinpath(sansbase, "SourceSans3-Italic.ttf"),
            :light => joinpath(sansbase, "SourceSans3-Light.ttf"),
            :lightitalic => joinpath(sansbase, "SourceSans3-LightItalic.ttf"),
            :medium => joinpath(sansbase, "SourceSans3-Medium.ttf"),
            :mediumitalic => joinpath(sansbase, "SourceSans3-MediumItalic.ttf"),
            :regular => joinpath(sansbase, "SourceSans3-Regular.ttf"),
            :semibold => joinpath(sansbase, "SourceSans3-SemiBold.ttf"),
            :semibolditalic => joinpath(sansbase, "SourceSans3-SemiBoldItalic.ttf")
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
