using Makie


"""
    hist2d!(ax, x, y; nbins=10, color=:viridis)

Plot a 2D histogram on the given axis `ax` with the data `x` and `y`. The number of bins in each direction is given by `nbins` and the colormap is given by `color`.
"""
function hist2d!(ax, x, y; bins=10, kwargs...)
    H, xedges, yedges = histogram2d(x, y, bins)
    xcenters = (xedges[1:end-1] + xedges[2:end]) / 2
    ycenters = (yedges[1:end-1] + yedges[2:end]) / 2
    heatmap!(ax, xcenters, ycenters, H, kwargs...)
end



function hist2d(x, y; bins=10, kwargs...)
    fig = Figure()
    ax = Axis(fig[1, 1])
    p = hist2d!(ax, x, y, bins=bins, kwargs...)
    return Makie.FigureAxisPlot(fig, ax, p)
end



"""
    histogram2d(x, y; bins=10)

Compute a 2D histogram of the data `x` and `y` with the number of bins in each direction given by `bins`.
"""
function histogram2d(x, y, bins::Tuple{AbstractVector, AbstractVector})
    xedges, yedges = bins
    Nx = length(xedges) - 1
    Ny = length(yedges) - 1

    H = zeros(Int, Nx, Ny)

    for (xx, yy) in zip(x, y)
        i = searchsortedfirst(xedges, xx) - 1
        j = searchsortedfirst(yedges, yy) - 1
        if i > 0 && i <= Nx && j > 0 && j <= Ny
            H[i, j] += 1
        end
    end

    return H, xedges, yedges
end


function histogram2d(x, y, bins::Tuple{Int, Int})
    x1 = x[isfinite.(x)]
    y1 = y[isfinite.(y)]

    xedges = range(minimum(x1), stop=maximum(x1), length=bins[1]+1)
    yedges = range(minimum(y1), stop=maximum(y1), length=bins[2]+1)
    histogram2d(x, y, (xedges, yedges))
end


function histogram2d(x, y, bins::Int)
    histogram2d(x, y, (bins, bins))
end


function histogram2d(x, y, bins::AbstractVector)
    histogram2d(x, y, (bins, bins))
end

