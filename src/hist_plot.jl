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
