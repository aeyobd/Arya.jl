using Makie


# """
#     hist2d!(ax, x, y; nbins=10, color=:viridis)
# 
# Plot a 2D histogram on the given axis `ax` with the data `x` and `y`. The number of bins in each direction is given by `nbins` and the colormap is given by `color`.
# """
# function hist2d!(ax, x, y; weights=ones(Int64, length(x)), bins=10, limits=nothing, kwargs...)
# 
#     if limits == nothing && bins isa Int
#         limits = ax.limits.val
#     end
#     H, xedges, yedges = histogram2d(x, y, bins, 
#         weights=weights, limits=limits)
#     xcenters = (xedges[1:end-1] + xedges[2:end]) / 2
#     ycenters = (yedges[1:end-1] + yedges[2:end]) / 2
#     heatmap!(ax, xcenters, ycenters, H; kwargs...)
# end
# 
# 
# 
# function hist2d(x, y; bins=10, kwargs...)
#     fig = Figure()
#     ax = Axis(fig[1, 1])
#     p = hist2d!(ax, x, y; bins=bins, kwargs...)
#     return Makie.FigureAxisPlot(fig, ax, p)
# end


function Makie.convert_arguments(P::Type{<:BarPlot}, h::Arya.Histogram)
    xy = Makie.convert_arguments(P, Arya.midpoint(h.bins), h.values)
    return PlotSpec(P, xy...; width = diff(h.bins), gap=0, dodge_gap=0)
end

function Makie.convert_arguments(p::Type{<:Scatter}, h::Arya.Histogram)
	return (Arya.midpoint(h.bins), h.values)
end

function Makie.convert_arguments(p::Type{<:Lines}, h::Arya.Histogram)
	return (Arya.midpoint(h.bins), h.values)
end


function Makie.convert_arguments(P::Type{<:Heatmap}, h::Arya.Histogram2D)
    x = h.xbins
    y = h.ybins
    z = h.values

    return (x, y, z)
end


function Makie.convert_arguments(P::Type{<:Heatmap}, h::Arya.KDE2D)
    x = h.x
    y = h.y
    z = h.values

    return (x, y, z)
end

@recipe(Hist2D) do scene
    Attributes(
        colorrange = theme(scene, :colorrange),
        colormap = theme(scene, :colormap),
        colorscale = identity,
        limits = nothing,
        bins = 20,
        weights = nothing
    )
end


function Makie.plot!(sc::Hist2D{<:Tuple{AbstractVector{<:Real}, AbstractVector{<:Real}}})
    x = vec(sc[1].val)
    y = vec(sc[2].val)
    
    if sc.limits.val == nothing
        # TODO: need alternative to current_axis()?
        sc.limits = current_axis().limits
    end

    h = histogram2d(x, y, sc.bins.val, 
        weights=sc.weights.val, limits=sc.limits.val
       )


    colorrange = calc_limits(h.values, sc.colorrange.val)
    println("using colorrange: ", colorrange)

    println("using limits: ", sc.limits.val)

    heatmap!(sc, h, colormap=sc.colormap.val, 
        colorrange=colorrange, 
        colorscale=sc.colorscale
        )
	sc
end



