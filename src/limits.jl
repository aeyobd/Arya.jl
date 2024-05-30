"""
    calc_limits(x[, limits])

Calculates the limits of x.
"""
function calc_limits(x, limits::Tuple=(nothing, nothing))
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


function calc_limits(x, limits::Nothing)
    return calc_limits(x, (nothing, nothing))
end




"""
    calc_limits(x, y[, limits])

Given both x and y data, calculates the limits of both x and y.
"""
function calc_limits(x, y, limits::Tuple{T, T}) where T <: Union{Nothing, Tuple}
    xlimits, ylimits = limits
    xlimits = calc_limits(x, xlimits)
    ylimits = calc_limits(y, ylimits)
    return xlimits, ylimits
end

function calc_limits(x, y, limits::Nothing=nothing)
    return calc_limits(x, y, (nothing, nothing))
end



function calc_limits(x, y, limits::Tuple)
    xlimits = limits[1:2]
    ylimits = limits[3:4]
    return calc_limits(x, y, (xlimits, ylimits))
end


