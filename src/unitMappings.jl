
# The conversion functions each field's units to units in SI.
const unitMappings = Dict{Symbol, Dict{String, Function}}(
    :temperature => Dict{String, Function}(
        "F"          => (value::Float64) -> (value - 32.0) * (5.0 / 9.0),
        "Fahrenheit" => (value::Float64) -> (value - 32.0) * (5.0 / 9.0),
        "C"          => (value::Float64) -> value,
        "Celsius"    => (value::Float64) -> value,
        "K"          => (value::Float64) -> value - 273.0,
        "Kelvin"     => (value::Float64) -> value - 273.0,
    ),
    :windSpeed => Dict{String, Function}(
        "Knots" => (value::Float64) -> value * 0.514444,
        "mph"   => (value::Float64) -> (value / 0.62137) * 1000.0 / (60 * 60),
        "k/hr"  => (value::Float64) -> value * 1000.0 / (60 * 60),
        "m/s"   => (value::Float64) -> value
    ),
    :windDirection => Dict{String, Function}(
        "degrees" => (value::Float64) -> value
    ),
    :pressure => Dict{String, Function}(
        "Pa"      => (value::Float64) -> value * 0.001,
        "Pascals" => (value::Float64) -> value * 0.001,
        "kPa"     => (value::Float64) -> value,
        "N/m2"    => (value::Float64) -> value * 0.001,
        "kgm/s2"  => (value::Float64) -> value,
        "bar"     => (value::Float64) -> value * 100.0,
        "mbar"    => (value::Float64) -> value * 0.1,
        "inHg"    => (value::Float64) -> value * 3.38639,
        "mmHg"    => (value::Float64) -> value * 0.133322
    ),
    :relativeHumidity => Dict{String, Function}(
        "percent" => (value::Float64) -> value
    ),
    :solarRadiation => Dict{String, Function}(
        "W/m2" => (value::Float64) -> value
    )
)
