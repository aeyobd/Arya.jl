module Arya

using Plots
using Requires
using Unitful, UnitfulAstro
import StatsBase: quantile

import PhysicalConstants.CODATA2018 as c

export c # useful for me

function __init__()
    # @require plotlyjs interactive_arya()
    add_arya()

    theme(:arya)
end # function


function add_arya()
    sty = PlotTheme(
        msw = 0,
        ms = 10,
        lw = 1,
        framestyle=:box,
        grid=false,
        minorticks=true,

       )

    add_theme(:arya, sty)
end
            

function freedman_diaconis(x)
    n = length(x)
    q75, q25 = quantile(x, [0.75, 0.25])
    h = 2 * (q75 - q25) / n^(1/3)
    return h
end

function calc_bins(x, min, max)
    N = freedman_diaconis(x)
    bins = collect(min:0.1:max)
    return bins
end


function hist2d(x, y; xlim=Nothing, ylim=Nothing, kwargs...)
    if xlim != Nothing
        xbins = calc_bins(x, xlim[1], xlim[2])
    end 
    if ylim != Nothing
        ybins = calc_bins(y, ylim[1], ylim[2])
    end


    p = histogram2d(x, y; bins=(xbins, ybins),
                    kwargs...)

    return p
end 

function set_ticks!(;tl=0.02)
    p = Plots.current()
    xticks, yticks = Plots.xticks(p)[1][1], Plots.yticks(p)[1][1]
    xl, yl = Plots.xlims(p), Plots.ylims(p)
    x1, y1 = zero(yticks) .+ xl[1], zero(xticks) .+ yl[1]
    sz = p.attr[:size]
    r = sz[1]/sz[2]
    dx, dy = tl*(xl[2] - xl[1]), tl*r*(yl[2] - yl[1])
    plot!([xticks xticks]', [y1 y1 .+ dy]', c=:black, labels=false)
    plot!([x1 x1 .+ dx]', [yticks yticks]', c=:black, labels=false, xlims=xl, ylims=yl)
    return Plots.current()
end

function _set_minor_ticks(;)
end


end # module

