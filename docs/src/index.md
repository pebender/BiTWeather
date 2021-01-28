
# BiTWeather.jl

```@meta
CurrentModule = BiTWeather
```

Welcome to the BiTWeather.jl. This documentation strives to provide you with everything you need to know to use BiTWeather.jl.

## What is BiTWeather.jl

BiTWeather.jl is a the collection of functions to enable a backyard gardener with SQL database stored weather data to perform calculations helpful to planting and maintaining their garden. I have been implementing functions as we have needed them for our garden. Right now, we are in the process of selecting some addition fruit trees. So, I have implemented various models for calculating chill. Because our microclimate is different from the nearby locations for which chill data is available, I felt using our own weather data could provide some better insight.

### Why the Name?

Since these are weather related routines, I felt Weather.jl would be a good name for the module. However, the name Weather.jl is very generic and I did not want the name of the module to conflict with the names of other modules. So, I have called it BiTWeather.jl instead.
BiT is an acronym for "Back in Thirty". "Back in Thirty" is the name of our house, garden and internet domain name. So, I felt prefacing the name with BiT was a good way to keep the module name unique while not completely obscuring its function.

## Our Equipment

I thought a detour to look at the equipment we use in conjunction with our [permaculture](https://en.wikipedia.org/wiki/Permaculture) garden.

- We collect weather data using an [Ambient Weather WS-1550-IP](https://ambientweather.com/amws1500.html) personal weather station.
- We transfer weather data to a SQL database using [Meteobridge](https://meteobridge.com/wiki/index.php/Home) rebranded as the [Ambient Weather WEATHERBRIDGE](https://ambientweather.com/amweatherbridge.html) for transferring weather data to a SQL database.
- We store weather data in a [MariaDB](https://mariadb.org) running on a [Synology DS718+](https://www.synology.com/).
- We upload weather data to [PWSWeather](https://www.pwsweather.com/) as [BACKINTHRITY](https://www.pwsweather.com/station/pws/BACKINTHIRTY) to enable our smart irrigation controllers to access the weather data.
- We control irrigation using [Orbit b-hyve](https://bhyve.orbitonline.com) smart irrigation controllers.
- We monitor water usage using a [Flume Smart Home Water Monitor](https://flumewater.com/).

## Weather Data

BiTWeather.jl reads, normalizes and formats weather data from a SQL database table using [`BiTWeather.read`](@ref). It uses this normalized and formatted weather data in other functions to perform calculations useful to the backyard gardener. While the output of these calculations is available for many locations, the results are not always sufficient.

## Chill Models

When deciding on fruit producing plants, the gardener wants to know whether or not the plants will set fruit where they live. For many plants, including varieties of fruit trees, varieties of cane berries and strawberries, a major contributing factor to whether or not the plant will set fruit is how much [chill](https://en.wikipedia.org/wiki/Chilling_requirement) the plant receives while dormant. People measure chill in different ways but the goal is the same: estimate whether or not there is enough chill during dormancy to set fruit.

BiTWeather.jl implements the following chill estimation models:

- [Cumulative Chill Hour](chill_CumulativeChillHour.md)
- [Cumulative Chill Unit (Utah)](chill_CumulativeChillUnit.md)
- [Cumulative Chill Portion (Dynamic)](chill_CumulativeChillPortion.md)
- [Mean Temperature](chill_MeanTemperature.md)

While the [Cumulative Chill Hour](chill_CumulativeChillHour.md) and [Cumulative Chill Unit](chill_CumulativeChillUnit.md) models have proven to be adequate chill estimators for cold climates, the have proven to be less reliable predictors for temperate climate. For temperate climates, the [Cumulative Chill Portion](chill_CumulativeChillPortion.md) [Mean Temperature](chill_MeanTemperature.md) models have proven to be more reliable chill estimators.

BiTWeather.jl makes the chill models available through its [`BiTWeather.chill`](@ref) function.
