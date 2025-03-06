import Makie: automatic
import Colors
import Makie
import MakieCore

"""
    errscatter(xs, ys; xerror, yerror, kwargs...)

Plots a scatter plot with error bars.
Note `alpha` attribute is broken in errorbars. 
"""
@recipe ErrorScatter begin
    "The x errors of the data"
    xerror = nothing
    "The y errors of the data"
    yerror = nothing

    "The color of the markers and errorbars"
    color = @inherit markercolor

    "The color of the errorbars"
    errorcolor = automatic
    "The colormap of the errorbars"
    errorcolormap = automatic
    "The colorrange of the errorbars"
    errorcolorrange = automatic
    "The alpha of the errorbars"
    erroralpha = automatic

    "The linewidth of the errorbars"
    linewidth = @inherit linewidth

    "Sets the size of the markers"
    size = @inherit markersize
    "Sets the strokecolor of the markers"
    strokecolor = @inherit markerstrokecolor
    "Sets the strokewidth of the markers"
    strokewidth = @inherit markerstrokewidth
    "Sets the marker type"
    marker = @inherit marker

    MakieCore.mixin_generic_plot_attributes()...
    MakieCore.mixin_colormap_attributes()...

    cycle = [:color]

end


function Makie.plot!(p::ErrorScatter)
    x = p[1]
    y = p[2]

    real_erroralpha = Observable{Any}()
    map!(real_erroralpha, p.alpha, p.erroralpha) do alpha, ealpha
        ealpha === automatic ? alpha : ealpha
    end

    real_errorcolor  = Observable{Any}()
    map!(real_errorcolor, p.color, p.errorcolor) do col, ecol
        if ecol === automatic
            return to_color(col)
        else
            return to_color(ecol)
        end
    end

    # real_errorcolor[] = (real_errorcolor.val, real_alpha[])

    real_errorcolormap = Observable{Any}()
    map!(real_errorcolormap, p.colormap, p.errorcolormap) do cmap, ecmap
        ecmap === automatic ? cmap : ecmap
    end

    real_errorcolorrange = Observable{Any}()
    map!(real_errorcolorrange, p.colorrange, p.errorcolorrange) do crange, ecrange
        ecrange === automatic ? crange : ecrange
    end


    errorbar_kwargs = Dict(
        :linewidth => p.linewidth,
        :color => real_errorcolor,
        :colormap => real_errorcolormap,
        :colorrange => real_errorcolorrange,
        :alpha => real_erroralpha,
        :inspectable => p.inspectable,
    )


    for key in keys(errorbar_kwargs)
        s = string(errorbar_kwargs[key])
        if length(s) > 159
            s = s[1:150] * "..."
        end
        println(key, " ", s)
    end

    if p.xerror.val !== nothing
        errorbars!(p, x, y, p.xerror, direction=:x; errorbar_kwargs...)
    end

    if p.yerror.val !== nothing
        errorbars!(p, x, y, p.yerror, direction=:y; errorbar_kwargs...)
    end

    scatter!(p, x, y, 
        color = p.color, 
        strokecolor = p.strokecolor,
        strokewidth = p.strokewidth,
        marker = p.marker,
        markersize = p.size,
        colormap = p.colormap,
        colorscale = p.colorscale,
        colorrange = p.colorrange,
        inspectable = p.inspectable,
        alpha = p.alpha,
    )


    return p
end
