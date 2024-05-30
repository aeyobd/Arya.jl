
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
