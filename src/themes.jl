const pt_to_in = 1/72

COLORS = Makie.wong_colors()

function theme_arya()
    arya = Theme(
        fontsize=20,
        px_per_unit=5, # controls resolution for rasterization
        pt_per_unit=1, # 1 unit = 1 pt, so 1 inch = 72 units = 72*px_per_unit pixels
        colormap=:magma,
        fonts = (;
            regular = Makie.texfont(:regular),
            bold = Makie.texfont(:bold),
            italic =  Makie.texfont(:italic),
            bold_italic =  Makie.texfont(:bolditalic),
            ),

        Axis = ( 
            xminorticksvisible = true,
            yminorticksvisible = true,
            xminorticks = IntervalsBetween(5),
            yminorticks = IntervalsBetween(5),
            xticksmirrored=true,
            yticksmirrored = true,
            xtickalign=1,
            xminortickalign=1,
            ytickalign=1,
            yminortickalign=1
        ),

        CairoMakie = (; px_per_unit=5, type="png"),
        GLMakie = (; px_per_unit=5)

    )

    return arya
end


function add_arya()
    arya_theme = PlotTheme(;
        msc = :auto,
        framestyle=:box,
        grid=false,
        minorticks=true,
        dpi=400,
        fmt=:png,
        make_font_settings(typeface="Times")...
       )

    add_theme(:arya, arya_theme)
end


function make_font_settings(;fontsize=12, typeface="Helvetica")
    small = floor(Int, 0.8*fontsize)
    large = ceil(Int, 1.2*fontsize)
    medium = fontsize

    return Dict(
        :fontfamily=>typeface,

        :plot_titlefontsize=>large,
        :titlefontsize=>large,
        :annotationfontsize=>small,

        :colorbar_tickfontsize=>small,
        :colorbar_titlefontsize=>medium,
        :legend_font_pointsize=>small,
        :legend_title_font_pointsize=>medium,

        :guidefontsize=>medium,
        :tickfontsize=>small,
    )
end
