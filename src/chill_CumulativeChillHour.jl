import DataFrames
import Statistics

"""
```julia
    chill(::Val{:CumulativeChillHour}, weatherData::DataFrame)::DataFrame
```

Implements the [Cumulative Chill Hour](chill_CumulativeChillHour.md) model.

# Arguments

- `weatherData::DataFrames.DataFrame`: The weather data used for calculating
    the accumulated chill hours. `weatherData` must be formatted to match the
    output of [`BiTWeather.read`](@ref) and contain at least the :temperature`
    field.

# Return

- A `DataFrames.DataFrame` containing the chill hours indexed by
    year/month/day/hour. The returned columns are: year, month, day, hour,
    temperature, ``\\Delta y(n)``, and ``y(n)``.

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
    weatherData::DataFrames.DataFrame = BiTWeather.read(configuration, range, fields)
    chillData::DataFrames.DataFrame = BiTWeather.chill(Val(:CumulativeChillHour), weatherData)
    println(chillData)
```
"""
function chill(::Val{:CumulativeChillHour}, weatherData::DataFrames.DataFrame)::DataFrames.DataFrame

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
        y_nMinus1::Float64: The accumulated chill hours after the previous
            interval's calculation
    Returns:
        Result:
            delta_y_n::Float64: The number of chill hours from this interval.
            y_n::Float64: The accumulated chill hours at the completion of this
                interval.
        State:
            y_nMinus1
    ------------------------------------------------------------------------- =#
    function calculate(temperature::Float64, y_nMinus1::Float64)

        theta_n::Float64 = (temperature * (9.0 / 5.0)) + 32.0

        if     theta_n <  32.0
            delta_y_n::Float64 = 0.0
        elseif theta_n <= 45.0
            delta_y_n = 1.0
        else
            delta_y_n = 0.0
        end

        y_n::Float64 = y_nMinus1 + delta_y_n

        return delta_y_n, y_n, y_n
    end

    cch::DataFrames.DataFrame = weatherData

    # Determine the hourly temperature.
    gdf::DataFrames.GroupedDataFrame = DataFrames.groupby(cch, [:year, :month, :day, :hour])
    cch = DataFrames.combine(gdf,
        [:temperature] .=> Statistics.mean .=> [:temperature]
    )
    DataFrames.select!(cch, [:year, :month, :day, :hour, :temperature])
    DataFrames.sort!(cch, [:year, :month, :day, :hour])

    delta_y::Vector{Float64} = []
    y::Vector{Float64} = []

    y_nMinus1::Float64 = 0.0
    for row in DataFrames.eachrow(cch)
        delta_y_n::Float64, y_n::Float64, y_nMinus1 = calculate(row.temperature, y_nMinus1)
        push!(delta_y, delta_y_n)
        push!(y, y_n)
    end

    cch[!, :delta_y_n] = delta_y
    cch[!, :y_n] = y

    for name in DataFrames.propertynames(cch)
        if eltype(cch[!, name]) == Float64
            cch[!, name] = round.(cch[!, name], digits = 2)
        end
    end

    return cch
end

"""
```julia
    chillPlot(::Val{:CumulativeChillHour}, chillData::DataFrame)::PlotlyJS.Plot
```

Generates a plot of the [Cumulative Chill Hour](chill_CumulativeChillHour.md) model
data.

# Arguments

- `chillData::DataFrames.DataFrame`: The chill data used in generating the plot.
    `chillData` must be formated to match the output of
    [`BiTWeather.chill`](@ref) called with `Val(:CumulativeChillHour)`.

# Return

- A `PlotlyJS.Plot` containing a plot of the temperature and chill portion data.

# Example

```julia
    import DataFrames
    import Dates
    import PlotlyJS
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
    chillData = BiTWeather.chill(Val(:CumulativeChillHour), weatherData)
    plot::PlotlyJS.Plot = BiTWeather.chillPlot(Val(:CumulativeChillHour), chillData)
    PlotlyJS.display(plot)
```
"""
function chillPlot(::Val{:CumulativeChillHour}, chillData::DataFrames.DataFrame)::PlotlyJS.Plot
    return _chillPlot(chillData, :temperature, :y_n, "Cumulative Chill Hour", "Hours")
end
