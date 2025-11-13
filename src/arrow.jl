# Taken from MakieExtra.jl (JuliaAPlavin)
import Makie: documented_attributes

using AccessorsExtra: @modify, @set
using DataPipes: @pipe

filter_keys(pred, d::Dict) = Dict(k => v for (k, v) in pairs(d) if pred(k))
function Base.setindex(x::Attributes, value::Observable, key::Symbol)
    y = copy(x)
    y[key] = value
    return y
end
Base.setindex(x::Attributes, value, key::Symbol) = Base.setindex(x, Observable(value), key)


"""    arrow(position, direction; arrowstyle="-|>", ...)

Plots an arrow pointing at the physical direction `direction` centred at the position `position`. 
"""
@recipe ArrowHead () begin
    documented_attributes(Lines)...
    @modify($(documented_attributes(Makie.Scatter)).d) do d
        filter_keys(∉(keys(documented_attributes(Lines).d)), d)
    end...
end


function Makie.plot!(p::ArrowHead)
    point = p[1]
    direction = p[2]
    @assert length(point[]) == 2
    @assert length(direction[]) == 2
    
    scene = Makie.get_scene(p)

    markerangle = lift(scene.camera.projectionview, p.model, Makie.transform_func(p), scene.viewport, point, direction) do _, _, tfunc, _, p_0, dp

        points = (p_0, p_0+dp)
        ps_t = Makie.apply_transform.(Ref(tfunc), points)
        ps_pix = Makie.project.(Ref(scene), ps_t)
        dx, dy = ps_pix[2] - ps_pix[1]
        atan(dy, dx)
    end


    let
        attrs = @pipe let
            Makie.shared_attributes(p, Scatter)
            @set __[:rotation] = @lift($(markerangle) + 0)
        end
        s_point = @lift [$point]
        scatter!(p, attrs, s_point)
    end
end


