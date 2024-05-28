"""
    make_limits(x[, limits])

Calculates the limits of x.
"""
function make_limits(x, limits::Tuple=(nothing, nothing))
    lower, upper = limits

    filt = isfinite.(x)
    x = x[filt]

    if lower == nothing
        lower = minimum(x)
    end

    if upper == nothing
        upper = maximum(x)
    end

    return lower, upper
end


function make_limits(x, limits::Nothing)
    return make_limits(x, (nothing, nothing))
end



function _make_limits(x, y, limits::Tuple{T, T}) where T <: Union{Nothing, Tuple}
    xlimits, ylimits = limits
    xlimits = _make_limits(x, xlimits)
    ylimits = _make_limits(y, ylimits)
    return xlimits, ylimits
end

function _make_limits(x, y, limits::Nothing)
    return _make_limits(x, y, (nothing, nothing))
end



function _make_limits(x, y, limits::Tuple)
    xlimits = limits[1:2]
    ylimits = limits[3:4]
    return _make_limits(x, y, (xlimits, ylimits))
end


