import DataFrames
import Statistics

"""
```julia
    chill(::Val{:MeanTemperature}, weatherData::DataFrame)::DataFrame
```

Implements the [Mean Temperature](chill_MeanTemperature.md) model.

# Arguments

- `weatherData`: A `DataFrames.DataFrame` containing the weather data used for
    estimating the chill units. `weatherData` must be formatted to match the
    output of [`BiTWeather.read`](@ref) and contain at least the `:temperature` field.

# Return

- A `DataFrames.DataFrame` containing the chill units indexed by
    year/month/day/hour. The returned columns are: x and y.

For temperate climates, you want to use data from the coldest month of the year
for the calculation. Whereas, for cold climates, you want to use data from the
coldest two months of the year.

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
    rangeStart::Dates.Date = Dates.Date(year, 1, 1)
    rangeEnd::Dates.Date = Dates.Date(year, 1, 31)
    range::Tuple{Float64, Float64} = (rangeStart, rangeEnd)
    fields::Vector{Symbol} = [:temperature]
    weatherData = BiTWeather.read(configuration, range, fields)
    println(BiTWeather.chill(Val(:MeanTemperature), weatherData)
```
"""
function chill(::Val{:MeanTemperature}, weatherData::DataFrames.DataFrame)::DataFrames.DataFrame

    # The chill calculation requires the :temperature field.
    if !(:temperature in DataFrames.propertynames(weatherData))
        error("weatherData must contain the :temperature field")
    end

    mt::DataFrames.DataFrame = weatherData

    # Determine daily max and min temperatures.
    gdf::DataFrames.GroupedDataFrame = DataFrames.groupby(mt, [:year, :month, :day])
    mt = DataFrames.combine(gdf,
        [:temperature] .=> [maximum, minimum] .=> [:x_max_d, :x_min_d]
    )

    # Determine mean max and mean min temperatures.
    mt = DataFrames.combine(mt,
        [:x_max_d, :x_min_d] .=> Statistics.mean .=> [:x_max, :x_min]
    )

    # Determine mean temperature.
    mt[!, :x] = (mt.x_max .+ mt.x_min) ./ 2.0

    # Determine chill units.
    function y(x::Float64)::Float64
        return (-100.0 * x) + (5600.0 / 3.0)
    end
    mt[!, :y] = y.(mt.x)

    DataFrames.select!(mt, [:x, :y])

    for name in DataFrames.propertynames(mt)
        if eltype(mt[!, name]) == Float64
            mt[!, name] = round.(mt[!, name], digits = 2)
        end
    end

    return mt
end