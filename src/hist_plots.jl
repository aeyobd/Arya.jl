import Makie: convert_arguments, plot!
import Makie: needs_tight_limits
import Makie

import DensityEstimators
import DensityEstimators: histogram2d


function convert_arguments(P::Type{<:Makie.BarPlot}, h::DensityEstimators.Histogram)
    xy = convert_arguments(P, midpoints(h.bins), h.values)
    return PlotSpec(P, xy...; width = diff(h.bins), gap=0, dodge_gap=0)
end

function convert_arguments(p::Type{<:Makie.Scatter}, h::DensityEstimators.Histogram)
    return (midpoints(h.bins), h.values)
end

function convert_arguments(p::Type{<:Makie.Lines}, h::DensityEstimators.Histogram)
    return (midpoints(h.bins), h.values)
end


function convert_arguments(P::Type{<:Makie.Heatmap}, h::DensityEstimators.Histogram2D)
    x = h.xbins
    y = h.ybins
    z = h.values

    return (x, y, z)
end


function convert_arguments(P::Type{<:Makie.Heatmap}, h::DensityEstimators.KDE2D)
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
        weights = nothing,
        normalization = :none
    )
end


function plot!(sc::Hist2D{<:Tuple{AbstractVector{<:Real}, AbstractVector{<:Real}}})
    x = vec(sc[1][])
    y = vec(sc[2][])
    
    if sc.limits[] == nothing
        # TODO: need alternative to current_axis()?
        sc.limits = current_axis().limits
    end

    h = histogram2d(x, y, sc.bins[], 
                    weights=sc.weights[], limits=sc.limits[], normalization=sc.normalization[]
       )


    colorrange = DensityEstimators.calc_limits(h.values, sc.colorrange[])
    println("using colorrange: ", colorrange)

    #println("using limits: ", sc.limits.val)

    heatmap!(sc, h, colormap=sc.colormap[], 
        colorrange=colorrange, 
        colorscale=sc.colorscale
        )
	sc
end


# removes whitespace in axis like Heatmap
Makie.needs_tight_limits(::Hist2D) = true

