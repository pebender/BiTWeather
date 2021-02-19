

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