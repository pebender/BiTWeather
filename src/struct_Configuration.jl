

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
    methods to a field in the SQL database table. The BiTWeather.jl module fields and
    allowed units are

    - `:dateTime`
    - `:pressure`: *`"kPa"`*, `"bar"`, `"inHg"`, `"kgm/s2"`, `"mbar"`, `"mmHg"`, `"N/m2"`, `"Pa"`, `"Pascals"`
    - `:relativeHumidity`: *`"percent"`*
    - `:solarRadiation`: *`"W/m2"`*
    - `:temperature`: *`"C"`*, *`"Celsius"`*, `"F"`, `"Fahrenheit"`, `"K"`, `"Kelvin"`
    - `:windDirection`: *`"degrees"`*
    - `:windSpeed`:  *`"m/s"`*, `"Knots"`, `"k/hr"`, `"mph"`

The mapping for `:dateTime` is required. The SI units to which all other units
are converted appear at the beginning of the list in italic.

See [`configuration_example`](@ref) for an example `Configuration`.
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