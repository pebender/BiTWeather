__precompile__()

module BiTWeather

const UnitMapping = Dict{String, Function}
const UnitMappings = Dict{Symbol, UnitMapping}

# The conversion functions each field's units to units in SI.
const unitMappings = UnitMappings(
    :temperature => UnitMapping(
        "F"          => (value::Float64) -> (value - 32.0) * (5.0 / 9.0),
        "Fahrenheit" => (value::Float64) -> (value - 32.0) * (5.0 / 9.0),
        "C"          => (value::Float64) -> value,
        "Celsius"    => (value::Float64) -> value,
        "K"          => (value::Float64) -> value - 273.0,
        "Kelvin"     => (value::Float64) -> value - 273.0,
    ),
    :windSpeed => UnitMapping(
        "Knots" => (value::Float64) -> value * 0.514444,
        "mph"   => (value::Float64) -> (value / 0.62137) * 1000.0 / (60 * 60),
        "k/hr"  => (value::Float64) -> value * 1000.0 / (60 * 60),
        "m/s"   => (value::Float64) -> value
    ),
    :windDirection => UnitMapping(
        "degrees" => (value::Float64) -> value
    ),
    :pressure => UnitMapping(
        "Pa"      => (value::Float64) -> value,
        "Pascals" => (value::Float64) -> value,
        "kPa"     => (value::Float64) -> value / 1000.0,
        "N/m2"    => (value::Float64) -> value,
        "kgm/s2"  => (value::Float64) -> value,
        "bar"     => (value::Float64) -> value / 100000.0,
        "mbar"    => (value::Float64) -> value / 100.0,
        "inHg"    => (value::Float64) -> value * 3386.39,
        "mmHg"    => (value::Float64) -> value * 133.32239
    ),
    :relativeHumidity => UnitMapping(
        "percent" => (value::Float64) -> value
    ),
    :solarRadiation => UnitMapping(
        "W/m2" => (value::Float64) -> value
    )
)

"""
    FieldMapping

# Constructors

```julia
FieldMapping(name::String, units::Union{String, Nothing})
FieldMapping(; name::String, units::Union{String, Nothing} = nothing)
```

# Arguments

- `name`: The name of field in the SQL database table.
- `units`: The units of the field values in the SQL database table.

Provides the information needed to map a field understood by the BiTWeather.jl
module functions to a field in the SQL database table.
"""
struct FieldMapping
    name::String
    units::Union{String, Nothing}
end

function FieldMapping(; name::String, units::Union{String, Nothing} = nothing)
    return FieldMapping(name, units)
end

"""
    Configuration

# Constructors

```julia
Configuration(dsn::String, table::String, fieldMappings::Dict{Symbol, FieldMapping})
Configuration(; dsn::String, table::String, fieldMappings::Dict{Symbol, FieldMapping})
```

# Arguments

- `dsn`: A Data Source Name (DSN) that can connect to the SQL database
    and access `table`.
- `table`: The SQL database table containing the weather data.
- `fieldMappings`: A dictionary of [`BiTWeather.FieldMapping`](@ref) entries, each
    of which provides a mapping from a field understood by the BiTWeather.jl module
    methods to a field in the SQL database table. The BiTWeather.jl module fields are
    `:dateTime`, `:temperature`, `:windSpeed`, `:windDirection`, `:pressure`,
    `:relativeHumidity`, and `solarRadiation`. The mapping for `:dateTime` is
    required.

# Examples

## Example: Configuring ODBC on MacOS for Connecting to MariaDB

- Download and install the [MariaDB ODBC connector](https://downloads.mariadb.org/connector-odbc/).
- Configure the [ODBC](http://juliadatabases.github.io/ODBC.jl/stable/) module with a DSN on MacOS by running the following in REPL

```julia
    import Pkg
    Pkg.add("ODBC")
    import ODBC

    ODBC.adddriver("MariaDB", "/Library/MariaDB/MariaDB-Connector-ODBC/libmaodbc.dylib")
    ODBC.adddsn("meteobridge", "MariaDB",
                SERVER="mariadb.backinthirty.net", DATABASE="meteobridge",
                UID="<username>", PWD="<password>")
```

## Example: Using BiTWeather.Configuration

```julia
    import BiTWeather

    configuration = BiTWeather.Configuration(
        dsn = "meteobridge",
        table = "backinthirty",
        fieldMappings = Dict(
            :dateTime => BiTWeather.FieldMapping(
                name = "DateTime"
            ),
            :temperature => BiTWeather.FieldMapping(
                name = "TempOutNow",
                units = "F"
            ),
            :windSpeed => BiTWeather.FieldMapping(
                name = "WindSpeedNow",
                units = "mph"
            ),
            :windDirection => BiTWeather.FieldMapping(
                name = "WindDirNow",
                units = "degrees"
            ),
            :pressure => BiTWeather.FieldMapping(
                name = "PressNow",
                units = "inHg"
            ),
            :relativeHumidity => BiTWeather.FieldMapping(
                name = "HumOutNow",
                units = "percent"
            ),
            :solarRadiation => BiTWeather.FieldMapping(
                name = "SolRadNow",
                units = "W/m2"
            )
        )
    )
```
"""
struct Configuration
    dsn::String
    table::String
    fieldMappings::Dict{Symbol, FieldMapping}

    function Configuration(dsn, table, fieldMappings)

        for (fieldName, fieldMapping) in fieldMappings
            if fieldName != :dateTime && !(fieldName in keys(unitMappings))
                error("""Unknown field $(fieldName).""")
            end
            if fieldName != :dateTime
                if isnothing(fieldMapping.units)
                    error(""""units" must be set for $(fieldName)".""")
                end
                units = keys(unitMappings[fieldName])
                if !(fieldMapping.units in units)
                    error("""The units of $(fieldName) must be one of $(units).""")
                end
            end
        end

        return new(dsn, table, fieldMappings)
    end
end

function Configuration(; dsn::String, table::String, fieldMappings::Dict{Symbol, FieldMapping})::Configuration

    return Configuration(dsn, table, fieldMappings)
end

export FieldMapping
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
