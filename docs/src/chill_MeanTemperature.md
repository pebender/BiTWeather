# Mean Temperature

## Model Overview

The Mean Temperature model is explained in [Chilling Accumulation: its Importance and Estimation](https://aggie-horticulture.tamu.edu/stonefruit/chillacc.html). The model was developed for use in temperate climates by people who do not have access to hourly temperature measurements but do have have access to the temperature measurements from a max/min thermometer (also known as a high/low thermometer).

The model maps the mean temperature over the coldest month of the year to the total number of chill units using a relationship based on measured data. The mean temperature is calculated by averaging the mean of the maximum temperatures and mean minimum temperatures.

## Max/Min Thermometer Emulation

To emulate a max/min thermometer, [`Weather.chill`](@ref) calculates the daily maximum ``x_{max}(d) = \Theta_{max}(d)`` and minimum ``x_{min}(d) = \Theta_{min}(d``) temperatures from the weather data's temperature measurements using

```math

x_{max}(d) = \Theta_{max}(d)
=
\max_{n \in d} \Theta_n(d)

```

```math

x_{min}(d) = \Theta_{min}(d)
=
\min_{n \in d} \Theta_n(d)

```

where ``\Theta_n(d)`` is the temperature in ``\degree C`` of measurement ``n`` on day ``d``. After that, [`Weather.chill`](@ref) applies the Mean Temperature model.

## Model Implementation

First, [`Weather.chill`](@ref) calculates the mean maximum temperature ``x_{max} = \overline{\Theta_{max}}`` and the mean minimum temperature ``x_{min} = \overline{\Theta_{min}}`` using

```math

x_{max} =
\frac{1}{{d_2 - d_1 + 1}}
\cdot
\sum_{d=d_1}^{d_2}
x_{max}(d)
=
\overline{\Theta_{max}} = 
\frac{1}{{d_2 - d_1 + 1}}
\cdot
\sum_{d=d_1}^{d_2}
\Theta_{max}(d)

```

```math

x_{min} =
\frac{1}{{d_2 - d_1 + 1}}
\cdot
\sum_{d=d_1}^{d_2}
x_{min}(d)
=
\overline{\Theta_{min}} = 
\frac{1}{{d_2 - d_1 + 1}}
\cdot
\sum_{d=d_1}^{d_2}
\Theta_{min}(d)

```

where ``d_1`` is the first day of the calculation period and ``d_2`` is the last day of the calculation period. After that, it calculates the mean temperature ``x = \overline{\Theta}`` using

```math

x =
\frac{x_{max} + x_{min}}{2}
=
 \overline{\Theta}
=
\frac{
    \overline{\Theta_{max}}
    +
    \overline{\Theta_{min}}
}{2}

```

The data in Figure 1 of [Chilling Accumulation: its Importance and Estimation](https://aggie-horticulture.tamu.edu/stonefruit/chillacc.html) shows the mapping from mean temperature to total chill units. This mapping can be closely approximated by the linear equation

```math

y = m \cdot x + b

```

where

```math

x_0 = \frac{5 \degree C}{9 \degree F} \cdot
(62 \degree F - 32 \degree F) = \frac{50}{3} \degree C
\space,\space
y_0 = 200\space \text{chill units}

```

```math

x_1 = \frac{5 \degree C}{9 \degree F} \cdot (44 \degree F - 32 \degree F) = \frac{20}{3} \degree C
\space,\space
y_1 = 1200\space \text{chill units}

```

```math

m = \frac{y_1 - y_0}{x_1 - x_0} = -100 \space \frac{\text{chill units}}{\degree C}
\space,\space
b = - m * x_0 + y_0 = \frac{5600}{3} \space \text{chill units}

```

## Software Name Mappings

Because of naming restrictions imposed by the Julia language and Julia coding style, I cannot use the parameter, variable and function names from this summary for the parameter, variable and function names in the program. So, I have mapped names in the summary to names in the program while attempting to keep them consistent.

### Parameter Name Mappings

### Variable Name Mappings

- ``\Theta_n \Rightarrow`` temperature

### Equation Name Mappings

- ``x_{max}(d) \Rightarrow`` x_max_d
- ``x_{min}(d) \Rightarrow`` x_min_d
- ``x_{max} \Rightarrow`` x_max
- ``x_{min} \Rightarrow`` x_min
- ``x \Rightarrow`` x
- ``y \Rightarrow`` y
