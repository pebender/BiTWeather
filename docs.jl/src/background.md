
# Background

## Why the Name?

Since the module is a collection of weather related functions, I felt Weather.jl would be a good name for the module. However, the name Weather.jl is very generic and I did not want the name of my module to conflict with the name of someone else's weather module. So, I decided to call it BiTWeather.jl instead.

BiT is an acronym for "Back in Thirty". "Back in Thirty" is the name of our house, garden and internet domain. So, I felt prefacing the Weather.jl with BiT to form BiTWeather.jl was a good way to keep the module name unique while not completely obscuring its function.

## Our Equipment

We have a [permaculture](https://en.wikipedia.org/wiki/Permaculture) garden. We use several pieces of equipment in conjunction with the garden. Most of the equipment helps in collecting an analyzing weather data. The other equipment helps in managing water usage.

- We collect weather data using an [Ambient Weather WS-1550-IP](https://ambientweather.com/amws1500.html) personal weather station.
- We transfer weather data to a SQL database using a [Meteobridge](https://meteobridge.com/wiki/index.php/Home) rebranded as the [Ambient Weather WEATHERBRIDGE](https://ambientweather.com/amweatherbridge.html).
- We store weather data in a [MariaDB](https://mariadb.org) running on a [Synology DS718+](https://www.synology.com/).
- We upload weather data to [PWSWeather](https://www.pwsweather.com/) as [BACKINTHRITY](https://www.pwsweather.com/station/pws/BACKINTHIRTY) to enable our smart irrigation controllers to access the weather data.
- We control irrigation using [Orbit b-hyve](https://bhyve.orbitonline.com) smart irrigation controllers.
- We monitor water usage using a [Flume Smart Home Water Monitor](https://flumewater.com/).

Yes, this equipment is overkill. However, I have at least some justification for these toys.

## Our Climate

We live in San Diego.

San Diego's proximity to the ocean, the desert and the mountains results in four distinct climate regions: costal, inland, mountain and desert. However, because of local topography, there are many microclimates within these climate regions. My grandfather, father and I all live(d) in San Diego. Yet the plants and trees that are successful where each of us live(d) differ. So, in order to determine the plants with the best chance of success where I live, I need to know my specific weather. So, I collect my own weather data.

It seems San Diego is either in a drought or just about to enter a drought most of the time. So, it is important to both minimize our water usage[^1]. So, I use weather data assisted irrigation and monitor how we are using water.

---

Last Reviewed on 20 February 2021

[^1]: In addition to reducing water usage, people in California should make sure their property absorbs the water from rainfall rather then directing it down the storm drains. While this can reduce their own water usage, the bigger benefit is that the rainwater ends up in the water table rather than the ocean.
