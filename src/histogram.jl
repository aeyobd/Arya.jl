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


"""
calculates equal number bins over the array x with n values per bin.
"""
function make_equal_number_bins(x, n)
    return [percentile(x, i) for i in LinRange(0, 100, n+1)]
end


"""
    calc_histogram(x, bins; weights=Nothing)

Computes the histogram of a vector x with respect to the bins with optional weights. Returns the bin edges and the histogram.
"""
function calc_histogram(x::AbstractVector, bins::AbstractVector; weights=Nothing)
    if weights == Nothing
        weights = ones(Int64, length(x))
    end
    Nbins = length(bins) - 1
    hist = zeros(Nbins)
    for i in 1:Nbins
        idx = (x .>= bins[i]) .& (x .< bins[i+1])
        hist[i] = sum(weights[idx])
    end
    return bins, hist
end


function calc_histogram(x::AbstractVector, bins::Int=20; weights=Nothing, xlim=Nothing)
    if xlim == Nothing
        xlim = (minimum(x[isfinite.(x)]), maximum(x[isfinite.(x)]))
    end

    return calc_histogram(x, LinRange(xlim[1], xlim[2], bins); weights=weights)
end

