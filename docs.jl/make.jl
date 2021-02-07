__precompile__(false)

using Revise

import Documenter

using BiTWeather

Documenter.makedocs(
    sitename="BiTWeather.jl",
    modules=[BiTWeather],
    clean=true,
    format=Documenter.HTML(
        prettyurls=false
    ),
    pages = [
        "Introduction" => "index.md",
        "Chill Models" => [
            "chill_CumulativeChillHour.md",
            "chill_CumulativeChillUnit.md",
            "chill_CumulativeChillPortion.md",
            "chill_MeanTemperature.md"
        ],
        "API" => [
            "api_types.md",
            "api_functions.md"
        ],
        "Background" => "background.md"
    ]
)

