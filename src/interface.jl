# code to interface with varius external packages

import StatsBase as sb
import NearestNeighbors as nn



"""
    kth_nns(x, k=5, metric=:euclidean)

Compute the k-th nearest neighbor of each point in `x` using the Euclidean distance.

If x is a NxD matrix, then 
"""
function knn(x::AbstractArray; k=5, metric=:euclidean)
    if x isa AbstractVector
        x = x'
    end
    tree = nn.KDTree(x)
    idxs, dists = nn.knn(tree, x, k+1, true)

    idxs = [d[end] for d in idxs]
    dists = [d[end] for d in dists]
    return idxs, dists
end


function mean(x::AbstractArray; dims=:)
    return sb.mean(x, dims=dims)
end

function mean(x::AbstractArray, w::AbstractArray; dims=:)
    return sb.mean(x, sb.weights(w), dims=dims)
end

function std(x::AbstractArray; dims=:)
    return sb.std(x, dims=dims)
end

function std(x::AbstractArray, w::AbstractArray)
    return sb.std(x, sb.weights(w))
end


"""
    percentile(x, p)

The percentile of a vector `x` at `p`.
"""
function percentile(x::AbstractArray, p::Real)
    return quantile(x, p)
end


"""
    quantile(x, p)

"""
function quantile(x::AbstractArray, p::Real)
    return sb.quantile(x, p)
end
