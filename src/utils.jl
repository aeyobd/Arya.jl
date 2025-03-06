
function value(a::Real)
    a
end

function err(a::Real)
    0
end


function FigAxis(; kwargs...)
    fig = Figure()
    ax = Axis(fig[1, 1]; kwargs...)
    return fig, ax
end


"""
    gradient(y[, x])

computes the gradient (dy/dx) of a 2D function at the point (x, y).
assumes that x are sorted.
Returns a vector same length of x with endpoints using linear approximation.
Uses the 2nd order central difference method alla numpy.gradient.
"""
function gradient(y::AbstractVector{T}, x::AbstractVector) where T<:Real
    x = x
    y = y
    N = length(x)

    grad = Vector{T}(undef, N)

    grad[1] = (y[2] - y[1]) / (x[2] - x[1])
    grad[end] = (y[end] - y[end-1]) / (x[end] - x[end-1])
    for i in 2:(N-1)
        hs = x[i] - x[i-1]
        hd = x[i+1] - x[i]

        numerator = hs^2 * y[i+1] + (hd^2 - hs^2) * y[i] - hd^2*y[i-1]
        denom = hd*hs*(hd + hs)
        grad[i] = numerator/denom
    end
    return grad
end


"""
    gradient(y)
computes the gradient
"""
function gradient(y::AbstractVector{T}) where T<:Real
    x = collect(1.0:length(y))
    return gradient(y, x)
end
