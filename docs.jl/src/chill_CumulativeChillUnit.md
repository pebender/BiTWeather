# Cumulative Chill Unit (Utah)

## Model Overview

The [Cumulative Chill Unit](https://agrilife.org/stonefruit/popular-articles/chill-accumulation-its-importance-and-estimation/) model (also known as the Utah model) can be seen as a refinement of the [Cumulative Chill Hour](chill_CumulativeChillHour.md) model. The [Cumulative Chill Hour](chill_CumulativeChillHour.md) model accumulates a fixed amount of chill for every hour the temperature is in a temperature range defined by fixed upper and lower temperatures. In contrast, the Cumulative Chill Unit model has several different temperature thresholds, and the chill accumulated depends into which temperature range the current temperature falls. In addition, in certain temperature ranges the accumulated chill is actually reduced.

## Model Implementation

```math

\Delta y(n) =
\begin{cases}
    +0.0
    &   \space \text{for } \space \Theta_n \leq 34.0 \degree F \\
    +0.5
    &   \space \text{for } \space 34.0 \degree F < \Theta_n \leq 36.0 \degree F \\
    +1.0
    &   \space \text{for } \space 36.0 \degree F < \Theta_n \leq 48.0 \degree F \\
    +0.5
    &   \space \text{for } \space 48.0 \degree F < \Theta_n \leq 54.0 \degree F \\
    +0.0
    &   \space \text{for } \space 54.0 \degree F < \Theta_n \leq 60.0 \degree F \\
    -0.5
    &   \space \text{for } \space 60.0 \degree F < \Theta_n \leq 65.0 \degree F \\
    -1.0
    &   \space \text{for } \space \Theta_n > 65.0 \degree F
\end{cases}

```

and

```math

y(n) = y(n - 1) + \Delta y(n)

```

where $\Theta_n$ is the temperature during interval $n$, $\Delta y(n)$ are chill units accumulated during the 1-hour time interval $n$, and $y(n)$ is the total accumulated chill units up to and including the chill measured during the interval $n$. At the start, $y(0) = 0$.

## Software Name Mappings

Because of naming restrictions imposed by the Julia language and Julia coding style, I cannot use the parameter, variable and function names from this summary for the parameter, variable and function names in the program. So, I have mapped names in the summary to names in the program while attempting to keep them consistent.

### Parameter Name Mappings

### Variable Name Mappings

- ``\Theta_n \Rightarrow`` theta\_n

### Equation Name Mappings

- ``\Delta y(n) \Rightarrow`` delta\_y\_n
- ``y(n) \Rightarrow`` y\_n
- ``y(n - 1) \Rightarrow`` y\_nMinus1

---

Last Reviewed on 20 February 2021
