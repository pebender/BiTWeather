import DataFrames
import Dates
import ODBC

"""
```julia
read(configuration::Configuration,
        range::Union{Tuple{Union{Date, Nothing}, Union{Date, Nothing}}, Nothing},
        fields::Union{Vector{Symbol}, Nothing})::DataFrame
```

# Arguments

- `configuration::BiTWeather.Configuration`: A [`BiTWeather.Configuration`](@ref)
    providing the location and structure of the weather data.
- `range::Union{Tuple{Union{Dates.Date, Nothing}, Union{Dates.Date, Nothing}}, Nothing}`:
    The date range of the records to retrieve. A value of nothing for the
    lower, upper or both date bounds means there is no lower, upper or any
    date limit respectively. By selecting a date range here, you
    can do things such limit the records to the dates you need for your
    downstream processing.
- `fields::Union{Vector{Symbol}, Nothing}`: The fields to include from each
    record. A value of nothing means all fields included in
    `configure.fieldMappings` will be included. The `:dateTime` field will
    be included reguardless of the value of `fields`. By providing a list
    of fields here, you can limit the records to the fields you need for
    your downstream processing.

# Return

-  A `DataFrames.DataFrame` containing the requested weather data in SI units
    stored as Float64 and indexed by year/month/day/hour/minute/second.

Fetches and returns the weather data described by `configuration`. It
assumes the Julia environment is configured so `configure.dsn` is a DSN that is
able to connect to the SQL database containing the weather data and read the
table `configure.table`. It renames the `configure.table` fields using the
`configure.fieldMappings`. It parses the `:dateTime` field into separate
columns of integers containing the year, month, day, hour, minute and second.
All other fields are converted to SI units equivalents and stored as Float64
values. It drops any records with missing field values.

# Example

```julia
import DataFrames
import BiTWeather

configuration = BiTWeather.Configuration(
    dsn = "meteobridge",
    table = "backinthirty",
    fieldMappings = Dict(
        :dateTime =>    BiTWeather.FieldMapping(name = "DateTime",   units = nothing),
        :temperature => BiTWeather.FieldMapping(name = "TempOutNow", units = "F")
    )
)

weatherData::DataFrames.DataFrame = BiTWeather.read(configuration, nothing, nothing)
```
"""
function read(configuration::Configuration, range::Union{Tuple{Union{Dates.Date, Nothing}, Union{Dates.Date, Nothing}}, Nothing}, fields::Union{Vector{Symbol}, Nothing})::DataFrames.DataFrame

    fieldMappings::Dict{Symbol, FieldMapping} = configuration.fieldMappings

    #=
    Build the SQL query to retrieve the data columns.
    =#
    query::String = "SELECT"
    # Add the desired columns to the query.
    columns::Vector{Symbol} = []
    if isnothing(fields)
        columns = keys(fieldMappings)
    else
        for field in fields
            if field in keys(fieldMappings)
                push!(columns, field)
            end
        end
        if !(:dateTime in columns)
            push!(columns, :dateTime)
        end
    end
    filter!(x -> x != :dateTime, columns)
    query = "$(query) $(fieldMappings[:dateTime].name)"
    for column in columns
        query = "$(query), $(fieldMappings[column].name)"
    end
    query = "$(query) FROM"
    query = "$(query) $(configuration.table)"
    if !isnothing(range)
        if     !isnothing(range[1]) && !isnothing(range[2])
            query = "$(query) WHERE $(fieldMappings[:dateTime].name) BETWEEN '$(Dates.convert(Dates.DateTime, range[1]))' AND '$(Dates.convert(Dates.DateTime, range[2]))'"
        elseif !isnothing(range[1]) &&  isnothing(range[2])
            query = "$(query) WHERE $(fieldMappings[:dateTime].name) >= '$(Dates.convert(Dates.DateTime, range[1]))'"
        elseif  isnothing(range[1]) && !isnothing(range[2])
            query = "$(query) WHERE $(fieldMappings[:dateTime].name) < '$(Dates.convert(Dates.DateTime, range[2] + Dates.Day(1)))'"
        end
    end

    # Connect to the weather database.

    connection::ODBC.Connection = ODBC.Connection(configuration.dsn)
    # Read the requested fields.
    weatherData::DataFrames.DataFrame = ODBC.DBInterface.execute(connection, query) |> DataFrames.DataFrame

    # Drop records with missing values.
    DataFrames.dropmissing!(weatherData)

    # Set the field names.
    nameMappings::Dict{String, Symbol} = Dict()
    nameMappings[fieldMappings[:dateTime].name] = :dateTime
    for column in columns
        nameMappings[fieldMappings[column].name] = column
    end
    DataFrames.rename!(weatherData, nameMappings)

    # Set the field types.
    for fieldName in DataFrames.propertynames(weatherData)
        if fieldName != :dateTime
            weatherData[!, fieldName] = convert.(Float64, weatherData[!, fieldName])
        else
            weatherData[!, fieldName] = Dates.convert.(Dates.DateTime, weatherData[!, fieldName])
        end
    end

    # Set the field units.
    for fieldName in DataFrames.propertynames(weatherData)
        if fieldName != :dateTime
            weatherData[!, fieldName] = unitMappings[fieldName][fieldMappings[fieldName].units].(weatherData[!, fieldName])
        end
    end

    weatherData[!, :year] = Dates.year.(weatherData.dateTime)
    weatherData[!, :month] = Dates.month.(weatherData.dateTime)
    weatherData[!, :day] = Dates.day.(weatherData.dateTime)
    weatherData[!, :hour] = Dates.hour.(weatherData.dateTime)
    weatherData[!, :minute] = Dates.minute.(weatherData.dateTime)
    weatherData[!, :second] = Dates.second.(weatherData.dateTime)

    DataFrames.sort!(weatherData, [:year, :month, :day, :hour, :minute, :second])

    return weatherData
end
