import QuadGK: quadgk

F = Float64

"""
KDE(x, bandwidth; weights=nothing, kernel=gaussian_kernel, r_trunc=3)

# Fields

$(FIELDS)
"""
@kwdef struct KDE
    """sample points for density"""
    x::Vector{F}

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



@kwdef mutable struct KDE2D
    x::Vector{F}
    y::Vector{F}
    values::Matrix{F}
    kernel::Function
    r_trunc::F = 3
end



function gaussian_kernel(x::Real)
    return 1/sqrt(2π) * exp(-x^2/2)
end

function kernel_2d_gaussian(x::Real, y::Real)
    return 1/(2π) * exp(-0.5 * (x^2 + y^2))
end


function normalize_kernel(f::Function, r_trunc::Real)
    return quadgk(x -> f(x), -r_trunc, r_trunc)[1]
end



function calc_kde(x::AbstractArray, bandwidth::AbstractArray; 
        weights=nothing, 
        kernel=gaussian_kernel, 
        r_trunc=3, 
        limits=nothing,
        n_samples=1000
    )

    # TODO: account for bandwidth here
    low = calc_limits(x .- bandwidth, limits)[1]
    high = calc_limits(x .+ bandwidth, limits)[2]
    limits = (low, high)

    bins = make_bins(x, limits, n_samples)

    if weights == nothing
        weights = ones(length(x))
    end

    weights = weights / sum(weights)

    N = length(x)
    hist = zeros(length(bins))
    kde = KDE(bins, hist, bandwidth, kernel, r_trunc)

    for i in 1:N
        add_point!(kde, x[i], bandwidth[i], weights[i])
    end

    return kde
end


function calc_kde(x, bandwidth::Function=bandwidth_knn;
        weights=nothing,
        kernel=gaussian_kernel,
        r_trunc=3,
        limits=nothing, 
        n_samples=1000,
        η=1,
        kwargs...)

    bandwidth = η * bandwidth(x; kwargs...)
    return calc_kde(x, bandwidth,
                    weights=weights, 
                    kernel=kernel, 
                    r_trunc=r_trunc, 
                    limits=limits, 
                    n_samples=n_samples, 
                   )
end

function calc_kde(x, bandwidth::Real; kwargs...)
    return calc_kde(x, fill(bandwidth, length(x)), kwargs...)
end


function add_point!(kde::KDE, x, bandwidth, weight)
    dx = kde.r_trunc * bandwidth
    idx_l = bin_index_safe(kde.x, x - dx)
    idx_h = bin_index_safe(kde.x, x + dx)

    dens = kde.kernel.((kde.x[idx_l:idx_h] .- x) ./ bandwidth) ./ bandwidth

    kde.values[idx_l:idx_h] .+= weight .* dens
end




# =============================================================================
# 2D KDE 
# =============================================================================

"""
    kde2d
"""
function kde2d(x::Vector{Float64}, y::Vector{Float64}, bandwidth::AbstractVector; 
        bins=100, r_trunc::Float64=5.0, limits=nothing,
        weights=ones(length(x)), kernel=kernel_2d_gaussian
    ) 

    
    xlims, ylims = split_limits(limits)
    xlims = calc_limits(x, xlims)
    ylims = calc_limits(y, ylims)

    xgrid = make_bins(x, xlims, bins-1)
    ygrid = make_bins(y, ylims, bins-1)

    weights = weights / sum(weights)

    kde = KDE2D(x=xgrid, y=ygrid, 
                values=zeros(Float64, length(xgrid), length(ygrid)),
            kernel=kernel, r_trunc=r_trunc)

    # 2D KDE computation by looping over data points
    for k in 1:length(x)
        add_point!(kde, x[k], y[k], bandwidth[k], weights[k])
    end
    
    return kde
end


function kde2d(x, y, bandwidth::Function=bandwidth_knn; kwargs...)
    return kde2d(x, y, bandwidth(x, y), kwargs...)
end

function kde2d(x, y, bandwidth::Real; kwargs...)
    return kde2d(x, y, fill(bandwidth, length(x)), kwargs...)
end


function add_point!(kde::KDE2D, x::Real, y::Real, bandwidth::Tuple, weight::Real=1)
    idx_x, idx_y = kde_grid_indices(kde, x, y, bandwidth)

    for i in idx_x[1]:idx_x[2]
        for j in idx_y[1]:idx_y[2]
            zx = (x - kde.x[i]) / bandwidth[1]
            zy = (y - kde.y[j]) / bandwidth[2]

            kde.values[i, j] += weight * kde.kernel(zx, zy) / (bandwidth[1] * bandwidth[2])
        end
    end
end

function add_point!(kde::KDE2D, x::Real, y::Real, bandwidth::Real, weight::Real=1)
    add_point!(kde, x, y, (bandwidth, bandwidth), weight)
end


function kde_grid_indices(kde::KDE2D, xi::Real, yj::Real, bandwidth::Tuple)
    hx, hy = bandwidth

    dx = kde.r_trunc * hx
    dy = kde.r_trunc * hy
    # Find the indices of the grid points that are within the truncation range
    #
    idx_x_min = bin_index_safe(kde.x, xi - dx)
    idx_x_max = bin_index_safe(kde.x, xi + dx)
    idx_y_min = bin_index_safe(kde.y, yj - dy)
    idx_y_max = bin_index_safe(kde.y, yj + dy)

    return (idx_x_min, idx_x_max), (idx_y_min, idx_y_max)
end


function bin_index_safe(bins::Array, x::Real)
    idx = bin_index_left(bins, x)
    if idx < 1
        return 1
    elseif idx > length(bins)
        return length(bins)
    else
        return idx
    end
end
