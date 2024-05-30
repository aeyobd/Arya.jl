# code to interface with varius external packages

import StatsBase as sb
import StatsBase: quantile, percentile
import NearestNeighbors as nn



function kth_nn(x::AbstractArray; k=5, metric=:euclidean)
    tree = nn.KDTree(x, Euclidean())
    idxs, dists = knn(tree, x, k+1, true)

    dist = [d[end] for d in dists]
    return dists
end


function mean(x::AbstractArray)
    return sum(x) / length(x)
end

function mean(x::AbstractArray, w::AbstractArray)
    return sum(x .* w) / sum(w)
end

function std(x::AbstractArray)
    return sqrt(var(x))
end

function std(x::AbstractArray, w::AbstractArray)
    return sqrt(var(x, w))
end


function var(x::AbstractArray; df=1)
    return sum((x .- mean(x)).^2) / (length(x) - df)
end

function var(x::AbstractArray, w::AbstractArray; df=0)
    return sum(w .* (x .- mean(x, w)).^2) / (sum(w) - df)
end
