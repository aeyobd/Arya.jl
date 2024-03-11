
function freedman_diaconis(x)
    n = length(x)
    q75, q25 = quantile(x, [0.75, 0.25])
    h = 2 * (q75 - q25) / n^(1/3)
    return h
end

function calc_bins(x, min, max)
    N = freedman_diaconis(x)
    bins = collect(min:0.1:max)
    return bins
end

function hist(x; xlims=Nothing, kwargs...)
    if xlim != Nothing
        bins = calc_bins(x, xlims...)
    end 

    p = stephist(x; bins=bins, msw=1, kwargs...)

    return p
end


function hist2d(x, y; xlims=Nothing, ylims=Nothing, kwargs...)
    xbins = calc_bins(x, xlims)
    ybins = calc_bins(y, ylims)

    p = histogram2d(x, y; bins=(xbins, ybins),
                    kwargs...)

    return p
end 
