module Arya

using Plots
using Requires
using Unitful, UnitfulAstro
import StatsBase: quantile

import PhysicalConstants.CODATA2018 as c

export c # useful for me

const COLORS = ["#0173b2", "#de8f05", "#029e73", "#d55e00", "#cc78bc", 
          "#ca9161", "#fbafe4", "#949494", "#ece133", "#56b4e9"]


include("themes.jl")
include("histogram.jl")

function __init__()
    add_arya()
    init()
end



function init(mode=:default)
    if mode == :default
        set_default()
    elseif mode == :interactive
        set_interactive()
    elseif mode == :journal
        set_latex()
    elseif mode == :presentation
        set_presentation()
    else
        error("Mode $mode not recognized")
    end
end # function


function set_default()
    gr()
    theme(:arya)
end

function set_interactive()
    plotlyjs()
    theme(:arya, ticks=:native, framestyle=:axes)
end

function set_latex()
    pgfplotsx()
    theme(:arya)
end

function set_presentation()
    gr()
    theme(:arya)
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

function set_mpl_theme()
    rcParams = Plots.PythonPlot.matplotlib.rcParams
    rcParams["figure.dpi"] = 200
    rcParams["pdf.fonttype"] = 42

    rcParams["text.usetex"] = true
    rcParams["mathtext.fontset"] = "custom"
    rcParams["text.latex.preamble"] = "\\usepackage{amsmath} \\usepackage{txfonts} \\usepackage[T1]{fontenc}"
    rcParams["axes.formatter.use_mathtext"] = true
    rcParams["font.family"] = "serif"
    rcParams["text.antialiased"] = true

    lw = 1
    ms = 2.5
    L = 10/3
    l = L / 2
    rcParams["lines.linewidth"] = lw
    rcParams["lines.markersize"] = ms
    rcParams["axes.linewidth"] = lw
    rcParams["xtick.major.width"] = lw
    rcParams["ytick.major.width"] = lw
    rcParams["xtick.minor.width"] = lw/2
    rcParams["ytick.minor.width"] = lw/2

    rcParams["xtick.major.size"] = L
    rcParams["ytick.major.size"] = L
    rcParams["xtick.minor.size"] = l
    rcParams["ytick.minor.size"] = l

end


end # module

