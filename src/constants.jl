"""
```julia
configuration_example = Configuration(
    dsn = "meteobridge",
    table = "backinthirty",
    fieldMappings = Dict(
        :dateTime =>         FieldMapping(name = "DateTime",     units = nothing),
        :pressure =>         FieldMapping(name = "PressNow",     units = "inHg"),
        :relativeHumidity => FieldMapping(name = "HumOutNow",    units = "percent"),
        :solarRadiation =>   FieldMapping(name = "SolRadNow",    units = "W/m2"),
        :temperature =>      FieldMapping(name = "TempOutNow",   units = "F"),
        :windDirection =>    FieldMapping(name = "WindDirNow",   units = "degrees"),
        :windSpeed =>        FieldMapping(name = "WindSpeedNow", units = "mph")
    )
)
```

The example assumes the `meteobridge` DSN is configured. Below is an
explaination of how to do this under MacOS. 

- Download and install the [MariaDB ODBC connector](https://downloads.mariadb.org/connector-odbc/).
- Configure the [ODBC](http://juliadatabases.github.io/ODBC.jl/stable/) module
with a DSN on MacOS by running the following in REPL

```julia
import ODBC

ODBC.adddriver("MariaDB", "/Library/MariaDB/MariaDB-Connector-ODBC/libmaodbc.dylib")
ODBC.adddsn("meteobridge", "MariaDB",
            SERVER="mariadb.backinthirty.net", DATABASE="meteobridge",
            UID="<username>", PWD="<password>")
```
"""
configuration_example = Configuration(
    dsn = "meteobridge",
    table = "backinthirty",
    fieldMappings = Dict(
        :dateTime =>         FieldMapping(name = "DateTime",     units = nothing),
        :pressure =>         FieldMapping(name = "PressNow",     units = "inHg"),
        :relativeHumidity => FieldMapping(name = "HumOutNow",    units = "percent"),
        :solarRadiation =>   FieldMapping(name = "SolRadNow",    units = "W/m2"),
        :temperature =>      FieldMapping(name = "TempOutNow",   units = "F"),
        :windDirection =>    FieldMapping(name = "WindDirNow",   units = "degrees"),
        :windSpeed =>        FieldMapping(name = "WindSpeedNow", units = "mph")
    )
)
