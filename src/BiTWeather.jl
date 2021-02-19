__precompile__()

module BiTWeather

include("unitMappings.jl")

include("struct_Configuration.jl")
export Configuration

include("constants.jl")
export configuration_example

include("read.jl")
export read

include("chill_CumulativeChillHour.jl")
include("chill_CumulativeChillUnit.jl")
include("chill_CumulativeChillPortion.jl")
include("chill_MeanTemperature.jl")
export chill

include("chillPlot.jl")
export chillPlot

end
