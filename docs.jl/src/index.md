
# BiTWeather.jl

```@meta
CurrentModule = BiTWeather
```

Welcome to the BiTWeather.jl. This documentation strives to provide you with everything you need to know to use and understand BiTWeather.jl. So, the documentation

- Explains how to use the functions (i.e. the API),
- Explains the models implemented by the functions, and
- Provides references for further information about the models.

## What is BiTWeather.jl

BiTWeather.jl is a collection of functions that I have been writing to help with our backyard garden. It reads weather data stored in a SQL database and performs calculations we find helpful in planting and maintaining our garden. I implement the functions as we need them for our garden.

## Weather Data

BiTWeather.jl reads, normalizes and formats weather data from a SQL database table using [`BiTWeather.read`](@ref). It uses this normalized and formatted weather data in other functions to perform calculations useful to the backyard gardener. While the output of these calculations is available for many locations, the results are not always sufficient.

## Chill Models

When deciding on fruit producing plants, we want to know whether or not the plants will set fruit where we live. For many plants, including varieties of fruit trees, varieties of cane berries and strawberries, a major contributing factor to whether or not the plant will set fruit is how much [chill](https://en.wikipedia.org/wiki/Chilling_requirement) the plant receives while dormant. People measure chill in different ways but the goal is the same: estimate whether or not there is enough chill during dormancy to set fruit.

BiTWeather.jl implements the following chill estimation models:

- [Cumulative Chill Hour](chill_CumulativeChillHour.md)
- [Cumulative Chill Unit (Utah)](chill_CumulativeChillUnit.md)
- [Cumulative Chill Portion (Dynamic)](chill_CumulativeChillPortion.md)
- [Mean Temperature](chill_MeanTemperature.md)

While the [Cumulative Chill Hour](chill_CumulativeChillHour.md) and [Cumulative Chill Unit](chill_CumulativeChillUnit.md) models have proven to be adequate chill estimators for cold climates, the have proven to be less reliable predictors for temperate climate. For temperate climates, the [Cumulative Chill Portion](chill_CumulativeChillPortion.md) [Mean Temperature](chill_MeanTemperature.md) models have proven to be more reliable chill estimators.

BiTWeather.jl makes the chill models available through its [`BiTWeather.chill`](@ref) function. In addition, the results can be plotted using its [`BiTWeather.chillPlot`](@ref) function.

---

Last Reviewed on 07 February 2021
