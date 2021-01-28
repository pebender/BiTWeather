# BiTWeather.jl

## Overview

BiTWeather.jl is a collection of functions to enable a backyard gardener with weather data stored in a SQL database to perform calculations helpful to planting and maintaining their garden. I have been implementing functions as we have needed them for our garden. Right now, we are in the process of selecting some addition fruit trees. So, I have implemented various models for calculating chill. Because our microclimate is different from the nearby locations for which chill data is available, I felt using our own weather data could provide some better insight.

## Why the Name?

Since these are weather related functions, I felt Weather.jl would be a good name for the module. However, the name Weather.jl is very generic and I did not want the name of the module to conflict with the names of other modules. So, I decided to call it BiTWeather.jl instead. BiT is an acronym for "Back in Thirty". "Back in Thirty" is the name of our house, garden and internet domain. So, I felt prefacing the Weather.jl with BiT to form BiTWeather.jl was a good way to keep the module name unique while not completely obscuring its function.

## Documentation

I have written some documentation on the use BiTWeather.jl and on the inner workings of the BiTWeather.jl algorithms. The documentation can be found at: [BiTWeather.jl documentation](https://github.com/pebender/BiTWeather/documentation/index.html).
