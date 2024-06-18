# A collection of rules to determine
# bandwidth for KDE and histograms



function bandwidth_freedman_diaconis(x::AbstractVector)
    n = length(x)
    q25, q75 = quantile(x, [0.25, 0.75])
    iqr = q75 - q25
    h = 2 * iqr / n^(1/3)
    return h
end


function bins_sturge(x::AbstractVector)
    limits = calc_limits(x)
    n = length(x)
    h = (limits[2] - limits[1]) / (log2(n) + 1)
    return h
end


@doc raw"""
    scotts_bins(x)

The Scott's rule for the number of bins in a histogram.

```math
h = \frac{3.5 \sigma}{n^{1/3}}
```

where `n` is the number of observations and `σ` is the standard deviation of the data.

Scott, D. W. (1979). Biometrika. 66(3):605–10
"""
function bandwidth_scott(x::AbstractVector)
    n = length(x)
    σ = std(x)
    h = 3.5 * σ / n^(1/3)
    return h
end



@doc raw"""
    knuth_bins(x)

The Knuth's rule for the number of bins in a histogram.

```math
n = 
```


Knuth KH. 2019. Digital Signal Processing. 95:102581.
https://doi.org/10.1016/j.dsp.2019.102581
"""
function bins_knuth(x::AbstractVector)
    n = length(x)
    return h
end



@doc raw"""
    number_per_bin(x)

The recommended number of observations for equal-number histograms.

Derived based on Pearson's test

```math
k = 2n^{2/5}
```

where `n` is the number of observations.
"""
function number_per_bin(x::AbstractVector)
    n = length(x)
    return 2n^(2/5)
end



# Adaptive 1D methods for kde

@doc raw"""
    bandwidth_knn(x; k=5, η=1)

The bandwidth selection rule based on the k-nearest neighbors.

```math
h = \eta \frac{d_{k+1}}{\sqrt{k}}
```

where `d_{k+1}` is the distance to the k+1 nearest neighbor, `k` is the number of neighbors, and `η` is a scaling factor.
"""
function bandwidth_knn(x::AbstractArray; k=5, η=1.0)
    _, dists = knn(x, k=k)
    h = @. η * dists / sqrt(k)
    return h
end


function bandwidth_knn(x::AbstractVector, y::AbstractVector; k=5, η=1.0)
    X = hcat(x, y)'
    return bandwidth_knn(X, k=k, η=η)
end
