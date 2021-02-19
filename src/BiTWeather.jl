__precompile__()

module BiTWeather

include("stuct_UnitMappings.jl")
export FieldMapping

include("struct_Configuration.jl")
export Configuration

include("read.jl")

include("chillPlot.jl")

export read

include("chill_CumulativeChillHour.jl")
include("chill_CumulativeChillUnit.jl")
include("chill_CumulativeChillPortion.jl")
include("chill_MeanTemperature.jl")

export chill
export chillPlot

end
