import MakieCore: convert_arguments, plot!
import Makie: needs_tight_limits
using Makie



function convert_arguments(P::Type{<:BarPlot}, h::Arya.Histogram)
    xy = convert_arguments(P, Arya.midpoint(h.bins), h.values)
    return PlotSpec(P, xy...; width = diff(h.bins), gap=0, dodge_gap=0)
end

function convert_arguments(p::Type{<:Scatter}, h::Arya.Histogram)
	return (Arya.midpoint(h.bins), h.values)
end

function convert_arguments(p::Type{<:Lines}, h::Arya.Histogram)
	return (Arya.midpoint(h.bins), h.values)
end


function convert_arguments(P::Type{<:Heatmap}, h::Arya.Histogram2D)
    x = h.xbins
    y = h.ybins
    z = h.values

    return (x, y, z)
end


function convert_arguments(P::Type{<:Heatmap}, h::Arya.KDE2D)
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


function plot!(sc::Hist2D{<:Tuple{AbstractVector{<:Real}, AbstractVector{<:Real}}})
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

    #println("using limits: ", sc.limits.val)

    heatmap!(sc, h, colormap=sc.colormap.val, 
        colorrange=colorrange, 
        colorscale=sc.colorscale
        )
	sc
end


# removes whitespace in axis like Heatmap
Makie.needs_tight_limits(::Hist2D) = true



