using Measurements

value(a::Measurement) = a.val
value(a::Real) = a
err(a::Measurement) = a.err
err(a::Real) = 0


function Makie.convert_single_argument(y::Array{Measurement{T}}) where T
	return value.(y)
end


@recipe(ErrScatter) do scene
    Attributes(
        color = theme(scene, :markercolor),
		marker = :circle,
        xerr = nothing,
        yerr = nothing
    )
end


function Makie.plot!(sc::ErrScatter)
	x = sc[1]
	y = sc[2]

    if sc.xerr.val !== nothing
        errorbars!(sc, x, y, sc.xerr, direction=:x, color=sc.color)
    end

    if sc.yerr.val !== nothing
        errorbars!(sc, x, y, sc.yerr, direction=:y, color=sc.color)
    end

	scatter!(sc, x, y, color=sc.color, marker=sc.marker)

	sc
end

