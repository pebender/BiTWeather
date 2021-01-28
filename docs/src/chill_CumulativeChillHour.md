# Cumulative Chill Hour

## Model Overview

The Cumulative Chill Hour model is one of the most simplistic chill estimation methods. It counts the number of hours the temperature is between ``32 \degree F`` and ``45 \degree F``.

This simplistic chill estimation methods has proven sufficient for cold climates. However, it can underestimate the chill significantly in temperate climates. Therefore, for estimating chill for temperate climates it is better to use chill estimation methods better suited for temperate climate. Such methods include the [Cumulative Chill Portion](chill_CumulativeChillPortion.md) and the [Mean Temperature](chill_MeanTemperature.md) models.

## Model Implementation

```math

\Delta y(n) =
\begin{cases}
    0.0
    &   \space \text{for } \space \Theta_n < 32.0 \degree F \\
    1.0
    &   \space \text{for } \space 32.0 \degree F \leq \Theta_n \leq 45.0 \degree F \\
    0.0
    &   \space \text{for } \space \Theta_n > 45.0 \degree F
\end{cases}

```

and

```math

y(n) = y(n - 1) + \Delta y(n)

```

where $\Delta x(n)$ is chill units accumulated during the 1-hour time interval $n$, $y(n)$ is the total accumulated chill units up to and including the chill measured during the interval $n$, and $\Theta_n$ is the temperature during interval $n$. At the start, $y(0) = 0$.

## Software Name Mappings

Because of naming restrictions imposed by the Julia language and Julia coding style, I cannot use the parameter, variable and function names from this summary for the parameter, variable and function names in the program. So, I have mapped names in the summary to names in the program while attempting to keep them consistent.

### Parameter Name Mappings

### Variable Name Mappings

- ``\Theta_n \Rightarrow`` theta_n

### Equation Name Mappings

- ``\Delta y(n) \Rightarrow`` delta_y_n
- ``y(n) \Rightarrow`` y_n
- ``y(n - 1) \Rightarrow`` y_nMinus1
