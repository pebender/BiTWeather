import DataFrames
import Statistics

"""
```julia
    chill(::Val{:CumulativeChillUnit}, weatherData::DataFrame)::DataFrame
```

Implements the [Cumulative Chill Unit](chill_CumulativeChillUnit.md) model
(also known as the Utah model).

# Arguments

- `weatherData::DataFrames.DataFrame`: The weather data used for calculating
    the cumulative chill units. `weatherData` must be formatted to match the
    output of [`BiTWeather.read`](@ref) and contain at least the `:temperature`
    field.

# Return

- A `DataFrames.DataFrame` containing the chill units indexed by
    year/month/day/hour. The returned columns are: year, month, temperature,
    ``\\Delta y(n)``, and ``y(n)``.

# Example

```julia
    import DataFrames
    import Dates
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
            )
        )
    )

    year::Int = 2021
    rangeStart::Dates.Date = Dates.Date(year - 1, 11, 1)
    rangeEnd::Dates.Date = Dates.Date(year, 2, 28)
    range::Tuple{Float64, Float64} = (rangeStart, rangeEnd)
    fields::Vector{Symbol} = [:temperature]
    weatherData = BiTWeather.read(configuration, range, fields)
    println(BiTWeather.chill(Val(:CumulativeChillUnit), weatherData)
```
"""
function chill(::Val{:CumulativeChillUnit}, weatherData::DataFrames.DataFrame)::DataFrames.DataFrame

    # The chill calculation requires the :temperature field.
    if !(:temperature in DataFrames.propertynames(weatherData))
        error("weatherData must contain the :temperature field")
    end

    #= -------------------------------------------------------------------------
    This function performs the chill calculation for one interval. It is passed
    the temperature as well as the state needed to perform the calculation. It
    returns the result of the calculation and the state needed to perform the
    next interval's calculation.

    Arguments:
        temperature: The temperature.
        y_nMinus1::Float64: The accumulated chill units after the previous
            interval's calculation
    Returns:
        Result:
            delta_y_n::Float64: The number of chill units from this interval.
            y_n::Float64: The accumulated chill units at the completion of this
                interval.
        State:
            y_nMinus1
    ------------------------------------------------------------------------- =#
    function calculate(temperature::Float64, y_nMinus1::Float64)

        theta_n::Float64 = (temperature * (9.0 / 5.0)) + 32.0

        if     theta_n <= 34.0
            delta_y_n::Float64 =  0.0
        elseif theta_n <= 36.0
            delta_y_n =  0.5
        elseif theta_n <= 48.0
            delta_y_n =  1.0
        elseif theta_n <= 54.0
            delta_y_n =  0.5
        elseif theta_n <= 60.0
            delta_y_n =  0.0
        elseif theta_n <= 65.0
            delta_y_n = -0.5
        else
            delta_y_n = -1.0
        end

        y_n::Float64 = y_nMinus1 + delta_y_n

        return delta_y_n, y_n, y_n
    end

    ccu::DataFrames.DataFrame = weatherData

    # Determine the hourly temperature.
    gdf::DataFrames.GroupedDataFrame = DataFrames.groupby(ccu, [:year, :month, :day, :hour])
    ccu = DataFrames.combine(gdf,
        [:temperature] .=> Statistics.mean .=> [:temperature]
    )
    DataFrames.select!(ccu, [:year, :month, :day, :hour, :temperature])
    DataFrames.sort!(ccu, [:year, :month, :day, :hour])

    delta_y::Vector{Float64} = []
    y::Vector{Float64} = []

    y_nMinus1::Float64 = 0.0
    for row in DataFrames.eachrow(ccu)
        delta_y_n::Float64, y_n::Float64, y_nMinus1 = calculate(row.temperature, y_nMinus1)
        push!(delta_y, delta_y_n)
        push!(y, y_n)
    end

    ccu[!, :delta_y_n] = delta_y
    ccu[!, :y_n] = y

    for name in DataFrames.propertynames(ccu)
        if eltype(ccu[!, name]) == Float64
            ccu[!, name] = round.(ccu[!, name], digits = 2)
        end
    end

    return ccu
end