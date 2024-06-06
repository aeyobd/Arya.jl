import Base: @kwdef

midpoint(x) = (x[1:end-1] + x[2:end]) ./ 2


@kwdef struct Histogram
    bins::AbstractVector
    values::AbstractVector

    normalization::Symbol = :count
    closed::Symbol = :left
end

Base.iterate(h::Histogram) = (h.bins, h.weights)


@kwdef struct RollingHistogram
    sample_points::AbstractVector
    values::AbstractVector

    bandwidth
    normalization::Symbol
end


@kwdef struct Histogram2D
    bins::Tuple{AbstractVector, AbstractVector}
    weights::AbstractVector
end



"""
    histogram(x[, bins]; weights, normalization, limits, closed)

Computes the histogram of a vector x with respect to the bins with optional weights. Returns the bin edges and the histogram.
"""
function histogram(x::AbstractVector, bins=bandwidth_freedman_diaconis; 
        weights=ones(Int64, length(x)), 
        normalization=:count,
        limits=nothing,
        closed=:left,
    )

    limits = calc_limits(x, limits)
    bins = make_bins(x, limits, bins)

    if closed == :left
        bin_index = bin_index_left
    elseif closed == :right
        bin_index = bin_index_right
    else
        error("closed must be either :left or :right")
    end

    N = length(bins)
    hist = zeros(eltype(weights), N-1)

    for i in eachindex(x)
        idx = bin_index(bins, x[i])
        if idx != -1
            hist[idx] += weights[i]
        end
    end

    h =  Histogram(bins=bins, values=hist, normalization=normalization, closed=closed)
    h = normalize(h, normalization)

    return h
end



"""
    rolling_histogram(x[, bandwidth]; weights, normalization, limits, samples)

Computes the rolling histogram of a vector x with respect to the bandwidth. Returns the bin edges and the histogram.

"""
function rolling_histogram(x::AbstractVector, bandwidth=bandwidth_freedman_diaconis;
        weights=ones(Int64, length(x)), 
        normalization=:pdf, 
        limits=nothing, 
        samples=10000,
    )

    if bandwidth isa Function
        bandwidth = bandwidth(x)
    end
    limits = calc_limits(x, limits)

    limits = (limits[1] - bandwidth, limits[2] + bandwidth)

    bins = make_bins(x, limits, samples-1)

    hist = zeros(length(bins))

    N = length(x)

    for i in 1:N
        # range of bins >= x[i] - bandwidth and <= x[i] + bandwidth
        idx_l = searchsortedfirst(bins, x[i] - bandwidth)
        idx_h = searchsortedlast(bins, x[i] + bandwidth)

        if idx_l < 1
            println("idx_l < 1")
        elseif idx_h > length(bins)
            println("idx_h > length(bins)")
        end

        # boundary truncation
        idx_l = max(1, idx_l)
        idx_h = min(length(bins), idx_h)
        width = (idx_h - idx_l + 1)

        hist[idx_l:idx_h] .+= weights[i] / width
    end

    h =  RollingHistogram(x=bins, weights=hist, bandwidth=bandwidth, normalization=normalization)
    normalize!(h, normalization; dx=bins[2] - bins[1])

    return h
end


function normalize(hist::Histogram, normalization=:pdf)
    if normalization == :pdf
        pdf = sum(hist.values .* diff(hist.bins))
        values = hist.values ./ pdf
    elseif normalization == :count
        values = hist.values 
    else
        error("normalization must be either :pdf or :count")
    end

    return Histogram(bins=hist.bins, values=values, normalization=normalization, closed=hist.closed)
end


function normalize!(hist::RollingHistogram, normalization=:pdf; dx=nothing)

    if normalization == :pdf
        pdf = sum(hist.values .* dx)
        values = hist.values ./ pdf
    elseif normalization == :count
        values = hist.values 
    else
        error("normalization must be either :pdf or :count")
    end

    hist.values .= values
end



"""
bin_index is index of last bin  <= x
as such bin_index is in 0 to length(bins)
and either extrema represent a value outside the bins
"""
function bin_index_left(bins, x)
    if x == bins[end]
        return length(bins) - 1
    end
    idx = searchsortedlast(bins, x) 
    if (idx < 1) || (idx >= length(bins))
        idx = -1
    end

    return idx
end


"""
bin_index is index of last bin  <= x
as such bin_index is in 0 to length(bins)
and either extrema represent a value outside the bins
"""
function bin_index_right(bins, x)
    if x == bins[1]
        return 1
    end
    idx = searchsortedfirst(bins, x) - 1 
    if (idx < 1) || (idx >= length(bins))
        idx = -1
    end
    return idx
end




function make_bins(x, limits, bins::Nothing=nothing; bandwidth=nothing)
    if bandwidth == nothing
        error("either bins or bandwidth must be specified")
    end

    bins = limits[1]:bandwidth:(limits[2]+bandwidth)

    return bins
end


function make_bins(x, limits, bins::Int)
    bins = LinRange(limits[1], limits[2], bins+1)

    return bins
end


function make_bins(x, limits, bins::AbstractVector)
    if !issorted(bins)
        error("bins must be sorted")
    end

    if length(unique(bins)) != length(bins)
        error("bins must be unique")
    end
    return bins
end


function make_bins(x, limits, bins::Function)
    h = bins(x)
    return make_bins(x, limits, bandwidth=h)
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


"""
calculates equal number bins over the array x with n values per bin.
"""
function make_equal_number_bins(x, n)
    return [percentile(x, i) for i in LinRange(0, 100, n+1)]
end


