using Makie


"""
    hist2d!(ax, x, y; nbins=10, color=:viridis)

Plot a 2D histogram on the given axis `ax` with the data `x` and `y`. The number of bins in each direction is given by `nbins` and the colormap is given by `color`.
"""
function hist2d!(ax, x, y; weights=ones(Int64, length(x)), bins=10, limits=nothing, kwargs...)

    if limits == nothing && bins isa Int
        limits = ax.limits.val
    end
    H, xedges, yedges = histogram2d(x, y, bins, 
        weights=weights, limits=limits)
    xcenters = (xedges[1:end-1] + xedges[2:end]) / 2
    ycenters = (yedges[1:end-1] + yedges[2:end]) / 2
    heatmap!(ax, xcenters, ycenters, H; kwargs...)
end



function hist2d(x, y; bins=10, kwargs...)
    fig = Figure()
    ax = Axis(fig[1, 1])
    p = hist2d!(ax, x, y; bins=bins, kwargs...)
    return Makie.FigureAxisPlot(fig, ax, p)
end



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

    (xmin, xmax), (ymin, ymax) = _make_limits(x, y, limits)

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


function _make_limits(x, limits::Nothing)
    return _make_limits(x, (nothing, nothing))
end

function _make_limits(x, limits::Tuple)

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
