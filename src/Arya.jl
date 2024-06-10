module Arya

using Makie
using DocStringExtensions: TYPEDEF, FIELDS


export theme_arya
export COLORS, FigAxies

export err, value # measurements ext
export hist2d, hist2d!


include("interface.jl")
include("limits.jl")
include("bandwidth.jl")

include("histogram.jl")
include("histogram2d.jl")
include("errscatter.jl")
include("bayesian_blocks.jl")
include("knuth_hist.jl")

include("kde.jl")

include("hist_plots.jl")
include("themes.jl")


function value(a::Real)
    a
end

function err(a::Real)
    0
end

function FigAxis()
    fig = Figure()
    ax = Axis(fig[1, 1])
    return fig, ax
end

function __init__()
    set_theme!(theme_arya())
end

end # module
