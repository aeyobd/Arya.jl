"""
    calc_limits(x[, limits])

Calculates the limits of x. If limits is a tuple, it should be a 2-tuple of
lower and upper limits. If either limit is nothing, then the maximum/minimum of
x is used instead of that limit. Raises an error if the lower limit is greater
than the upper limit.
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

    if lower > upper
        error("Lower limit is greater than upper limit ($lower > $upper)")
    end

    return lower, upper
end


function calc_limits(x, limits::Nothing)
    return calc_limits(x, (nothing, nothing))
end


# 2D limits


"""
    calc_limits(x, y[, limits])

Given both x and y data, calculates the limits of both x and y.
Limits should be either a tuple of x limits and y limits, or a 4-tuple of xlow, xhigh, ylow, yhigh.
See documentation for calc_limits(x, limits) for the details.
"""
function calc_limits(x, y, limits::Tuple{Any, Any})
    xlimits, ylimits = limits
    xlimits = calc_limits(x, xlimits)
    ylimits = calc_limits(y, ylimits)
    return xlimits, ylimits
end

function calc_limits(x, y, limits::Nothing=nothing)
    return calc_limits(x, y, (nothing, nothing))
end



function calc_limits(x, y, limits::Tuple{Any, Any, Any, Any})
    xlimits = limits[1:2]
    ylimits = limits[3:4]
    return calc_limits(x, y, (xlimits, ylimits))
end


