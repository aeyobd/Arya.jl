

"""
    histogram2d(x, y, bins; weights, limits)

Compute a 2D histogram of the data `x` and `y` with the number of bins in each direction given by `bins`.
If bins is

Parameters
----------
x : AbstractVector
    The x data
y : AbstractVector
    The y data
bins :
    The bin edges in each direction
    if bins is an Int, then the number of bins in each direction is the same
    if bins is a Tuple{Int, Int}, then the number of bins in each direction is given by the tuple
    if bins is a Tuple{AbstractVector, AbstractVector}, then the bin edges are given by the tuple
weights : AbstractVector
    The weights of each data point
limits : Tuple{Tuple{Real, Real}, Tuple{Real, Real}}
    If bins is an Int, then the limits of the data,
    otherwise ignored
"""
function histogram2d(x, y, bins::Tuple{AbstractVector, AbstractVector}; weights=ones(Int64, length(x)), limits=nothing)

    xedges, yedges = bins
    Nx = length(xedges) - 1
    Ny = length(yedges) - 1

    H = zeros(eltype(weights), Nx, Ny)

    N = length(x)
    for k in 1:N
        i = searchsortedfirst(xedges, x[k]) - 1
        j = searchsortedfirst(yedges, y[k]) - 1
        if i > 0 && i <= Nx && j > 0 && j <= Ny
            H[i, j] += weights[k]
        end
    end

    return H, xedges, yedges
end


function histogram2d(x, y, bins::Tuple{Int, Int}; limits=nothing, kwargs...)
    x1 = x[isfinite.(x)]
    y1 = y[isfinite.(y)]

    (xmin, xmax), (ymin, ymax) = calc_limits(x, y, limits)

    xedges = range(xmin, stop=xmax, length=bins[1]+1)
    yedges = range(ymin, stop=ymax, length=bins[2]+1)
    histogram2d(x, y, (xedges, yedges); kwargs...)
end


function histogram2d(x, y, bins::Int; kwargs...)
    histogram2d(x, y, (bins, bins); kwargs...)
end


function histogram2d(x, y, bins::AbstractVector; kwargs...)
    histogram2d(x, y, (bins, bins); kwargs...)
end
