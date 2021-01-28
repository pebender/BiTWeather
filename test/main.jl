__precompile__()

using Revise

import CSV
import DataFrames
import Dates
import BiTWeather

function main()

    cfg = BiTWeather.Configuration(
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

    year::Int = 2021

#    choice::Symbol = :CumulativeChillHour
#    choice::Symbol = :CumulativeChillUnit
#    choice::Symbol = :CumulativeChillPortion
    choice::Symbol = :MeanTemperature

    if (choice == :CumulativeChillHour)
        startDate::Dates.Date = Dates.Date(year - 1, 9,  1)
        endDate::Dates.Date   = Dates.Date(year,     3,  1)
        range::Tuple{Dates.Date, Dates.Date} = (startDate, endDate)
        fields::Vector{Symbol} = [:temperature]
        @time weather::DataFrames.DataFrame = BiTWeather.read(cfg, range, fields)
        @time results::DataFrames.DataFrame = BiTWeather.chill(Val(:CumulativeChillHour), weather)
#        @time CSV.write("chill.csv", results)
println(results)
    elseif (choice == :CumulativeChillUnit)
        startDate = Dates.Date(year - 1, 9, 1)
        endDate   = Dates.Date(year,     3, 1)
        range  = (startDate, endDate)
        fields = [:temperature]
        @time weather = BiTWeather.read(cfg, range, fields)
        @time results = BiTWeather.chill(Val(:CumulativeChillUnit), weather)
#        @time CSV.write("chill.csv", results)
        println(results)
    elseif (choice == :CumulativeChillPortion)
        startDate = Dates.Date(year - 1, 9, 1)
        endDate   = Dates.Date(year,     3, 1)
        range  = (startDate, endDate)
        fields = [:temperature]
        @time weather = BiTWeather.read(cfg, range, fields)
        @time results = BiTWeather.chill(Val(:CumulativeChillPortion), weather)
#        @time CSV.write("chill.csv", results)
        println(results)
    elseif (choice == :MeanTemperature)
        startDate = Dates.Date(year, 1,  1)
        endDate   = Dates.Date(year, 1, 31)
        range  = (startDate, endDate)
        fields = [:temperature]
        @time weather = BiTWeather.read(cfg, range, fields)
        @time results = BiTWeather.chill(Val(:MeanTemperature), weather)
#        @time CSV.write("chill.csv", results)
        println(results)
    else
    end

    return
end

main()