
#=
The conversion functions for each field's allowed units to units into
SI units.
=#
const unitMappings = Dict{Symbol, Dict{String, Function}}(
    :pressure => Dict{String, Function}(
        "kPa"     => (value::Float64) -> value,
        "bar"     => (value::Float64) -> value * 100.0,
        "inHg"    => (value::Float64) -> value * 3.38639,
        "kgm/s2"  => (value::Float64) -> value,
        "mbar"    => (value::Float64) -> value * 0.1,
        "mmHg"    => (value::Float64) -> value * 0.133322,
        "N/m2"    => (value::Float64) -> value * 0.001,
        "Pa"      => (value::Float64) -> value * 0.001,
        "Pascals" => (value::Float64) -> value * 0.001
    ),
    :relativeHumidity => Dict{String, Function}(
        "percent" => (value::Float64) -> value
    ),
    :solarRadiation => Dict{String, Function}(
        "W/m2" => (value::Float64) -> value
    ),
    :temperature => Dict{String, Function}(
        "C"          => (value::Float64) -> value,
        "Celsius"    => (value::Float64) -> value,
        "F"          => (value::Float64) -> (value - 32.0) * (5.0 / 9.0),
        "Fahrenheit" => (value::Float64) -> (value - 32.0) * (5.0 / 9.0),
        "K"          => (value::Float64) -> value - 273.0,
        "Kelvin"     => (value::Float64) -> value - 273.0
    ),
    :windDirection => Dict{String, Function}(
        "degrees" => (value::Float64) -> value
    ),
    :windSpeed => Dict{String, Function}(
        "m/s"   => (value::Float64) -> value,
        "Knots" => (value::Float64) -> value * 0.514444,
        "k/hr"  => (value::Float64) -> value * 1000.0 / (60 * 60),
        "mph"   => (value::Float64) -> (value / 0.62137) * 1000.0 / (60 * 60)
    )
)
