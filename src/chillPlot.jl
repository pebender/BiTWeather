
import DataFrames
import Dates
import PlotlyJS

function _chillPlot(data::DataFrames.DataFrame, temperatureField::Symbol, chillField::Symbol, model::String , units::String)::PlotlyJS.Plot

    function xaxisItem(year::Int = 1, month::Int = 1, day::Int = 1, hour::Int = 0, minute::Int = 0, second::Int = 0)::Dates.DateTime
        return Dates.DateTime(year, month, day, hour, minute, second)
    end

    xaxis::Vector{Dates.DateTime} = []

    names::Vector{String} = DataFrames.names(data)
    if     ! ("year" in names)
        xaxis = [Dates.DateTime(1,1,1,0,0,0)]
    elseif ! ("month" in names)
        xaxis = xaxisItem.(data.year)
    elseif ! ("day" in names)
        xaxis = xaxisItem.(data.year, data.month)
    elseif ! ("hour" in names)
        xaxis = xaxisItem.(data.year, data.month, data.day)
    elseif ! ("minute" in names)
        xaxis = xaxisItem.(data.year, data.month, data.day, data.hour)
    elseif ! ("second" in names)
        xaxis = xaxisItem.(data.year, data.month, data.day, data.hour, data.minute)
    else
        xaxis = xaxisItem.(data.year, data.month, data.day, data.hour, data.minute, data.second)
    end

    xMin::Dates.DateTime = Dates.DateTime(
        Dates.year(xaxis[1]),
        Dates.month(xaxis[1]),
        Dates.day(xaxis[1])
    )

    xMax::Dates.DateTime = Dates.DateTime(
        Dates.year(xaxis[length(xaxis)]),
        Dates.month(xaxis[length(xaxis)]),
        Dates.day(xaxis[length(xaxis)])
    )

    tMin::Float64 = floor(min(data[!, temperatureField]...) / 5.0) * 5.0
    tMax::Float64 = ceil(max(data[!, temperatureField]...) / 5.0) * 5.0

    ticks::Int = convert(Int, (tMax - tMin) / 5.0)

    tTick::Int = ceil(Int, (tMax - tMin) / ticks)
    tMax = tMin + ticks * tTick


    cMin::Float64 = 0.0
    cMax::Float64 = max(data[!, chillField]...)

    cTick::Int = ceil(Int, (cMax - cMin) / ticks)
    cMax = cMin + ticks * cTick

    trace1 = PlotlyJS.scatter(;
        name = "Temperature",
        x = xaxis,
        y = data[!, temperatureField],
        xaxis = "x",
        yaxis = "y",
        line_color = "lightgreen",
    )
    
    trace2 = PlotlyJS.scatter(;
        name = "Chill",
        x = xaxis,
        y = data[!, chillField],
        xaxis = "x",
        yaxis = "y2",
        line_color = "blue"
    )

    layout = PlotlyJS.Layout(;
        title = model,
        xaxis_title = "Date",
        xaxis_range = [xMin, xMax],

        yaxis_title = "Temperature (in F)",
        yaxis_color = "lightgreen",
        yaxis_range = [tMin, tMax],
        yaxis_dtick = tTick,

        yaxis2_title = "Chill (in $(units))",
        yaxis2_color = "blue",
        yaxis2_range = [cMin, cMax],
        yaxis2_dtick = cTick,
        yaxis2_side = "right",
        yaxis2_overlaying = "y",

        showlegend = false
    )

    return PlotlyJS.Plot([trace1, trace2], layout)
end