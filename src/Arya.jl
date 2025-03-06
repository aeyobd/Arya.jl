module Arya

export theme_arya
export COLORS, FigAxis
export hist2d, hist2d!
export hist
export midpoints # from statsbase

export SmartMinorTicks, DefaultLinearTicks

using MakieCore
import MakieCore: @recipe
using DocStringExtensions: TYPEDEF, FIELDS
import StatsBase: midpoints

using DensityEstimators


include("utils.jl")
include("errscatter.jl")
include("hist_plots.jl")
include("themes.jl")


function __init__()
    set_theme!(theme_arya())
end



end # module
