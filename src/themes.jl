const pt_to_in = 1/72

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
