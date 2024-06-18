module AryaMeasurementsExt

# export value, err

using Measurements
using Makie
using Arya

import Measurements: value, uncertainty


function Makie.convert_single_argument(y::Array{Measurement{T}}) where T
	return Arya.value.(y)
end



end # module
