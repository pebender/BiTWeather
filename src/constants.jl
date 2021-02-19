"""
```julia
configuration_example = Configuration(
    dsn = "meteobridge",
    table = "backinthirty",
    fieldMappings = Dict(
        :dateTime => FieldMapping(
            name = "DateTime"
        ),
        :temperature => FieldMapping(
            name = "TempOutNow",
            units = "F"
        ),
        :windSpeed => FieldMapping(
            name = "WindSpeedNow",
            units = "mph"
        ),
        :windDirection => FieldMapping(
            name = "WindDirNow",
            units = "degrees"
        ),
        :pressure => FieldMapping(
            name = "PressNow",
            units = "inHg"
        ),
        :relativeHumidity => FieldMapping(
            name = "HumOutNow",
            units = "percent"
        ),
        :solarRadiation => FieldMapping(
            name = "SolRadNow",
            units = "W/m2"
        )
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
const configuration_example = Configuration(
    dsn = "meteobridge",
    table = "backinthirty",
    fieldMappings = Dict(
        :dateTime => FieldMapping(
            name = "DateTime"
        ),
        :temperature => FieldMapping(
            name = "TempOutNow",
            units = "F"
        ),
        :windSpeed => FieldMapping(
            name = "WindSpeedNow",
            units = "mph"
        ),
        :windDirection => FieldMapping(
            name = "WindDirNow",
            units = "degrees"
        ),
        :pressure => FieldMapping(
            name = "PressNow",
            units = "inHg"
        ),
        :relativeHumidity => FieldMapping(
            name = "HumOutNow",
            units = "percent"
        ),
        :solarRadiation => FieldMapping(
            name = "SolRadNow",
            units = "W/m2"
        )
    )
)
