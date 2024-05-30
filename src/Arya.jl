module Arya

using Makie
using DocStringExtensions: TYPEDEF, FIELDS


export theme_arya
export COLORS

export err, value # measurements ext


include("interface.jl")
include("limits.jl")
include("bandwidth.jl")
include("histogram.jl")
include("kde.jl")
include("errscatter.jl")
include("bayesian_blocks.jl")

include("themes.jl")

function value(a::Real)
    a
end

function err(a::Real)
    0
end

function __init__()
    set_theme!(theme_arya())
end

end # module
