module Arya

export theme_arya
export COLORS
export value, err, errscatter

using Makie
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

function __init__()
    set_theme!(theme_arya())
end


include("utils.jl")
include("plots.jl")
include("histogram.jl")

include("MeasurementsExt.jl")

end # module
