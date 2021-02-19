import DataFrames
import PlotlyJS
import Statistics

"""
```julia
chill(::Val{:CumulativeChillPortion}, weatherData::DataFrame)::DataFrame
```

Implements the [Cumulative Chill Portion](chill_CumulativeChillPortion.md) model
(also known as the Dynamic model).

# Arguments

- `weatherData::DataFrames.DataFrame`: The weather data used for calculating
    the accumulated chill portions. `weatherData` must be formatted to match the
    output of [`BiTWeather.read`](@ref) and contain at least the`:temperature`
    field.

# Return

- A `DataFrames.DataFrame` containing the chill portions indexed by
    year/month/day/hour. The returned columns are:  year, month, day, hour,
    temperature, ``x(n)``, ``\\Delta y(n)``, and ``y(n)``.

# Example

```julia
import DataFrames
import Dates
import BiTWeather

configuration = BiTWeather.Configuration(
    dsn = "meteobridge",
    table = "backinthirty",
    fieldMappings = Dict(
        :dateTime =>    BiTWeather.FieldMapping(name = "DateTime",   units = nothing),
        :temperature => BiTWeather.FieldMapping(name = "TempOutNow", units = "F")
    )
)

year::Int = 2021
rangeStart::Dates.Date = Dates.Date(year - 1, 9, 1)
rangeEnd::Dates.Date = Dates.Date(year, 2, 28)
range::Tuple{Float64, Float64} = (rangeStart, rangeEnd)
fields::Vector{Symbol} = [:temperature]
weatherData::DataFrames.DataFrame = BiTWeather.read(configuration, range, fields)
chillData::DataFrames.DataFrame = BiTWeather.chill(Val(:CumulativeChillPortion), weatherData)
println(chillData)
```
"""
function chill(::Val{:CumulativeChillPortion}, weatherData::DataFrames.DataFrame)::DataFrames.DataFrame

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
        x_0_n::Float64:
        y_nMinus1::Float64: The accumulated chill portions after the previous
            interval's calculation
    Returns:
        Result:
            delta_y_n::Float64: The number of chill portions from this interval.
            y_n::Float64: The accumulated chill portions at the completion of
                this interval.
        State:
            x_0_n
            y_nMinus1
    ------------------------------------------------------------------------- =#
    function calculate(temperature::Float64, x_0_n::Float64, y_nMinus1::Float64)

        e_0::Float64     = 4153.5
        e_1::Float64     = 12888.8
        a_0::Float64     = 1.395 * 10.0^5.0
        a_1::Float64     = 2.567 * 10.0^18.0
        f::Float64       = 0.4
        theta_f::Float64 = 4.0 + 273.0

        theta_n::Float64 = temperature + 273

        k_0_n::Float64       = a_0 * exp(-e_0 / theta_n)
        k_1_n::Float64       = a_1 * exp(-e_1 / theta_n)
        x_s_n::Float64       = k_0_n / k_1_n
        x_n::Float64         = x_s_n - (x_s_n - x_0_n) * exp(-k_1_n)
        p_n::Float64         = exp(4 * f * theta_f * (1 - (theta_f / theta_n))) /
                               (1 + exp(4 * f * theta_f * (1 - (theta_f / theta_n))))
        delta_y_n::Float64   = x_n < 1.0 ? 0.0 : p_n * x_n
        y_n::Float64         = y_nMinus1 + delta_y_n
        x_0_nPlus1::Float64  = x_n - delta_y_n

        return x_n, delta_y_n, y_n, x_0_nPlus1, y_n
    end

    ccp::DataFrames.DataFrame = weatherData

    # Determine the hourly temperature.
    gdf::DataFrames.GroupedDataFrame = DataFrames.groupby(ccp, [:year, :month, :day, :hour])
    ccp = DataFrames.combine(gdf,
        [:temperature] .=> Statistics.mean .=> [:temperature]
    )
    DataFrames.select!(ccp, [:year, :month, :day, :hour, :temperature])
    DataFrames.sort!(ccp, [:year, :month, :day, :hour])

    x::Vector{Float64} = []
    delta_y::Vector{Float64} = []
    y::Vector{Float64} = []

    x_0_n::Float64 , y_nMinus1::Float64 = 0.0, 0.0
    for row in DataFrames.eachrow(ccp)
        x_n::Float64, delta_y_n::Float64, y_n::Float64, x_0_n, y_nMinus1 = calculate(row.temperature, x_0_n, y_nMinus1)
        push!(x, x_n)
        push!(delta_y, delta_y_n)
        push!(y, y_n)
    end

    ccp[!, :x_n] = x
    ccp[!, :delta_y_n] = delta_y
    ccp[!, :y_n] = y

    for name in DataFrames.propertynames(ccp)
        if eltype(ccp[!, name]) == Float64
            ccp[!, name] = round.(ccp[!, name], digits = 2)
        end
    end

    return ccp
end

"""
```julia
chillPlot(::Val{:CumulativeChillPortion}, chillData::DataFrame)::PlotlyJS.Plot
```

Generates a plot of the [Cumulative Chill Portion](chill_CumulativeChillPortion.md)
data.

# Arguments

- `chillData::DataFrames.DataFrame`: The chill data used in generating the plot.
    `chillData` must be formated to match the output of
    [`BiTWeather.chill`](@ref) called with `Val(:CumulativeChillPortion)`.

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
        :dateTime =>    BiTWeather.FieldMapping(name = "DateTime",   units = nothing),
        :temperature => BiTWeather.FieldMapping(name = "TempOutNow", units = "F")
    )
)

year::Int = 2021
rangeStart::Dates.Date = Dates.Date(year - 1, 9, 1)
rangeEnd::Dates.Date = Dates.Date(year, 2, 28)
range::Tuple{Float64, Float64} = (rangeStart, rangeEnd)
fields::Vector{Symbol} = [:temperature]
weatherData::DataFrames.DataFrame = BiTWeather.read(configuration, range, fields)
chillData::DataFrames.DataFrame = BiTWeather.chill(Val(:CumulativeChillPortion), weatherData)
plot::PlotlyJS.Plot = BiTWeather.chillPlot(Val(:CumulativeChillPortion), chillData)
PlotlyJS.display(plot)
```
"""
function chillPlot(::Val{:CumulativeChillPortion}, chillData::DataFrames.DataFrame)::PlotlyJS.Plot
    return _chillPlot(chillData, :temperature, :y_n, "Cumulative Chill Portion (Dynamic)", "Portions")
end
