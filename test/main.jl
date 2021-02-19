__precompile__()

using Revise

import CSV
import DataFrames
import Dates
import PlotlyJS

import BiTWeather

function main(mode::Symbol, model::Union{Symbol, Nothing} = nothing)

    cfg::BiTWeather.Configuration = BiTWeather.configuration_example

    if mode == :chill

        year::Int = 2021

        parameters::Dict{Symbol, Dict{Symbol, Any}} = Dict(
            :CumulativeChillHour => Dict(
                :range => (Dates.Date(year - 1, 9, 1), Dates.Date(year, 3,  1))
            ),
            :CumulativeChillUnit => Dict(
                :range => (Dates.Date(year - 1, 9, 1), Dates.Date(year, 3,  1))
            ),
            :CumulativeChillPortion => Dict(
                :range => (Dates.Date(year - 1, 9, 1), Dates.Date(year, 3,  1))
            ),
            :MeanTemperature => Dict(
                :range => (Dates.Date(year, 1, 1), Dates.Date(year, 1,  31))
            )
        )

        range::Tuple{Union{Dates.Date, Nothing}, Union{Dates.Date, Nothing}} = parameters[model][:range]
        fields::Vector{Symbol} = [:temperature]
        @time weatherData::DataFrames.DataFrame = BiTWeather.read(cfg, range, fields)
        @time chillData::DataFrames.DataFrame = BiTWeather.chill(Val(model), weatherData)
        @time CSV.write("chill.csv", chillData)
        @time plot::PlotlyJS.Plot = BiTWeather.chillPlot(Val(model), chillData)
        PlotlyJS.display(plot)
    end

    return
end

#main(:chill, :CumulativeChillHour)
#main(:chill, :CumulativeChillUnit)
main(:chill, :CumulativeChillPortion)
#main(:chill, :MeanTemperature)