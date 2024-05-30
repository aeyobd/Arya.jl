module Arya

using Makie
using DocStringExtensions: TYPEDEF, FIELDS


export theme_arya
export COLORS
export value, err, errscatter


include("interface.jl")
include("limits.jl")
include("bandwidth.jl")
include("histogram.jl")
include("kde.jl")

include("MeasurementsExt.jl")

include("themes.jl")


function __init__()
    set_theme!(theme_arya())
end


end # module
