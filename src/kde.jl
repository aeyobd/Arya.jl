import QuadGK: quadgk

F = Float64

"""
KDE(x, bandwidth; weights=nothing, kernel=gaussian_kernel, r_trunc=3)

# Fields

$(FIELDS)
"""
@kwdef struct KDE
    """sample points for density"""
    sample_points::Vector{F}

    """the density"""
    values::Vector{F}

    """ the bandwidth of the distribution"""
    bandwidth::Union{Vector{F}, Function, F}

    """ The kernel function. Should take one argument (distance / 
    bandwidth) and return the kernel value. 
    Will be normalized by code."""
    kernel::Function
    r_trunc::F = 3
end


function gaussian_kernel(x::Real)
    return 1/sqrt(2π) * exp(-x^2/2)
end


function normalize_kernel(f::Function, r_trunc::Real)
    return quadgk(x -> f(x), -r_trunc, r_trunc)[1]
end



function kde(x::AbstractArray, bandwidth; 
        weights=nothing, 
        kernel=gaussian_kernel, 
        r_trunc=3, 
        limits=nothing,
        n_samples=1000
    )

    # TODO: account for bandwidth here
    limits = calc_limits(x, limits)

    bins = make_bins(x, limits, n_samples)


    if weights == nothing
        weights = ones(length(x))
    end

    weights = weights / sum(weights)

    if bandwidth isa Function
        bandwidth = bandwidth(x)
    end
    if bandwidth isa Real
        bandwidth = fill(bandwidth, length(x))
    end


    N = length(x)
    hist = zeros(length(bins))

    for i in 1:N
        # range of bins >= x[i] - bandwidth and <= x[i] + bandwidth
        bw = bandwidth[i]

        idx_l = searchsortedfirst(bins, x[i] - bw*r_trunc)
        idx_h = searchsortedlast(bins, x[i] + bw*r_trunc)

        if idx_l < 1
            println("idx_l < 1")
        elseif idx_h > length(bins)
            println("idx_h > length(bins)")
        end

        # boundary truncation
        idx_l = max(1, idx_l)
        idx_h = min(length(bins), idx_h)

        dens = kernel.((bins[idx_l:idx_h] .- x[i]) ./ bw) ./ bw

        hist[idx_l:idx_h] .+= weights[i] .* dens
    end

    return KDE(bins, hist, bandwidth, kernel, r_trunc)
end
