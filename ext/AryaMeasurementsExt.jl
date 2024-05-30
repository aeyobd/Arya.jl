module AryaMeasurementsExt

# export value, err

using Measurements
using Makie
using Arya

function Arya.value(a::Measurement) 
    a.val
end



function Arya.err(a::Measurement)
    a.err
end



function Makie.convert_single_argument(y::Array{Measurement{T}}) where T
	return Arya.value.(y)
end



end # module
