# Cumulative Chill Portion (Dynamic)

## Model Overview

The Cumulative Chill Portion model (also known as the Dynamic model) is a two step model that follows the equations below. The mathematical analysis and computer simulations can be found in the two papers

- ["The temperature dependence of dormancy breaking in plants: Mathematical analysis of a two-step model involving a cooperative transition"](https://doi.org/10.1016/S0022-5193(87)80221-7) (refered to as the "mathematical analysis" paper)
- ["The temperature dependence of dormancy breaking in plants: Computer simulation of processes studied under controlled temperatures"](https://doi.org/10.1016/S0022-5193(87)80237-0) (refered to as the "computer simulation" paper)

I have provided a summary of the papers so people do not need to track down and read the papers in order to understand the model. Hopefully, my summary is sufficient to accomplish that goal.

As mentioned, the model presented and analyzed in ["mathematical analysis"](https://doi.org/10.1016/S0022-5193(87)80221-7) paper is a two step model. It assumes there is a Dormancy Breaking Factor that is created and destroyed. It assumes the creation and destruction processes of this DBF each obey the [Arrhenius equation](https://en.wikipedia.org/wiki/Arrhenius_equation). Further, it assumes that after enough Dormancy Breaking Factor from the creation and destruction processes has accumulated, the accumulated amount is no longer reversible. The first step is the reversible creation and destruction of the DBF (refered to a Precurser of DBF (PDBF)). The second step is the transfer of the currently accumulated PDBF to the irreversible DBF (refered to as DBF).

The ["computer simulation"](https://doi.org/10.1016/S0022-5193(87)80237-0) paper introduces a refinement to the model to better reflect measured behavior. Instead of the transfer from PDBF to DBF being deterministic, the transfer is made probabilistic.

Through the [Arrhenius equations](https://en.wikipedia.org/wiki/Arrhenius_equation) used for PDBF creation and destruction, the model relies on the hidden parameters for the creation equations' activation energy and rate as well a the destruction equation's activation energy and rate. Thankfully, we can determine these hidden parameters from a observable parameters predicted by the model.

## Model Parameters

### Observable Parameters

The model predicts there is an optimum temperature at which chill accumulates most quickly. This is not unexpected. Previously observation derived models have been moving in this direction. First, the developers of the [Cumulative Chill Hour](chill_CumulativeChillHour.md) model observed there is a temperature above which there is no significant chill accumulation. Then they observed there is a temperature below which there is no significant chill accumulation. Later, the developers of the [Cumulative Chill Unit](chill_CumulativeChillUnit.md) model observed that chill accumulates less quickly when the temperature is near the edge of lower and upper temperature thresholds and more quickly when it is in the middle of the temperature range. We will call this optimum temperature ``\Theta^*`` and time between transfer of PDBF to DBF at this optimum temperature ``\tau^*``.

The model predicts there is a critical temperature above which no chill accumulates. This is not unexpected. The developers of both the [Cumulative Chill Hour](chill_CumulativeChillHour.md) and [Cumulative Chill Unit](chill_CumulativeChillUnit.md) models observed this behavior. We will call this temperature ``\Theta_c``

The model predicts that when the temperature cycles between temperatures that are above and below the optimum temperature, chill can accumulate more quickly than at the optimum temperature. This is unexpected. People developing chill models had not observed this behavior until after it was predicted by the math. However, this lack of prior observation is not unexpected. It can be difficult to recognize short term dynamics of a system, especially what the short term dynamics are counterintuitive. We will call the higher temperature ``\Theta_1``, the lower temperature ``\Theta_2``, the period of the cycle ``\pi_c`` and the relative time spent at the higher and lower temperatures ``\eta``.

### Hidden Parameters

Because of the creation and destruction of PDBF are each modeled an [Arrhenius equation](https://en.wikipedia.org/wiki/Arrhenius_equation), the model needs the four hidden parameters creation activation energy ``E_0``, the creation rate ``A_0``, the destruction activation ``E_1`` and destruction rate ``A_1``. We can derive these hidden parameters from the observable parameters using @eq:A1 A1, A2, A3 and A4 from the ["computer simulation"](https://doi.org/10.1016/S0022-5193(87)80237-0) paper. I included these for equations in the [Appendix](#Appendix) in case anyone needs to determine the hidden parameters for their own set of observable parameters.

### Parameter Values

For my implementation, I chose the first set of observable parameters from Table 1 in the ["computer simulation"](https://doi.org/10.1016/S0022-5193(87)80237-0) paper. I chose these parameters because these were the parameters used by paper's sample implementation and by many subsequent implementations of the model. These observable parameter values are

```math

\Theta^* = 281 \space \text{K}
\space,\space
\Theta_c = 287 \space \text{K}
\space,\space
\Theta_1 = 297 \space \text{K}
\space,\space
\Theta_2 = 279 \space \text{K}

```

```math

\tau^* = 30 \space \text{h} \space,\space
\pi_c = 24 \space \text{h} \space,\space
\eta = \frac{1}{3}

```

They yield the hidden parameter values

```math

E_0 = 4.1535\cdot 10^3 \space \text{K} \space , \space
E_1 = 1.28888 \cdot 10^4\space \text{K}
\\~\\

A_0 = 1.395 \cdot 10^5 \space ,\space
A_1 = 2.567 \cdot 10^{18}

```

## Model Implementation

The computer simulation uses a discrete implementation. We use a discrete implementation because there is no closed form solution for the continuous model.

The discrete implementation holds the temperature constant for a time interval ``n``. After updating the equations using this temperature, the implementation uses the updated values as the initial values for the next time interval ``n + 1`` and repeats the process.

For this discrete implementation, PDBF is given by

```math
x(n) = x_s(n) - (x_s(n) - x_0(n)) \cdot e^{-k_1(n)}

```

where

```math
\tag*{1.2}

x_s(n) = \frac{k_0(n)}{k_1(n)}

```

and

```math

k_0(n) = A_0 \cdot e^{- \frac{E_0}{\Theta_n}}
\space,\space
k_1(n) = A_1 \cdot e^{- \frac{E_1}{\Theta_n}}

```

 ``x(n)`` is the PDBF after the time interval ``n`` but before any transfer of PDBF to DBF. ``x_0(n)`` is the PDBF at the end of the previous time interval after any transfer of PDBF to DBF. ``x_s(n)`` is the steady state value of ``x(n)`` were the temperature constant for all values of ``n``. ``k_0(n)`` and ``k_1(n)`` are the rates of PDBF creation and destruction during the time interval, and ``\Theta_n`` is the temperature during the time interval.

When ``x(n) = 1``, there is a probability that the PDBF will transfer to DBF. This probability is given by the sigmoidal function

```math
p(n) =
\frac
{
    e^{
        4 \cdot \Theta_f^2 \cdot F
        \cdot
        (\frac{1}{\Theta_f} - \frac{1}{\Theta_n})
    }
}
{
    1
    +
    e^{
        4 \cdot \Theta_f^2 \cdot F
        \cdot
        (\frac{1}{\Theta_f} - \frac{1}{\Theta_n})
    }
}
=
\frac
{e^{4 \cdot F \cdot \Theta_f \cdot (1 - \Theta_f / \Theta_n)}}
{1 + e^{4 \cdot F \cdot \Theta_f \cdot (1 - \Theta_f / \Theta_n)}}

```

where

```math

\Theta_f = 277 \space \text{K}
\space,\space
F = 0.4 \space K^{-1}

```

where ``\Theta_f`` is the transition temperature and ``F`` is the slope at the transition temperature. ``\Theta_f`` and ``F`` are chosen based on observation.

Rather than flip a coin with bias ``p(n)`` each time ``x(n) = 1``, we transfer ``p(n)`` amount of ``x(n)`` to ``y(n)`` each time ``x(n) = 1``. While not correct for any giving instance of ``x(n) = 1``, it is approximately correct after many occurrences of the same value of ``\Theta_n`` and has the advantage of making the ``x(n)`` and ``y(n)`` deterministic for a given sequence of ``\Theta_n``.

Under these assumptions, the transfer of PDBF to DBF is given by ``\Delta y(n)``, DPF is given by ``y(n)`` and the initial PDBF for the next time interval is given by ``x_0(n + 1)``. At the start of the simulation, ``x_0(n)`` and ``y(n)`` with zero.

```math

\Delta y(n) =
\begin{cases}
    0
    & \text{if } x(n) < 1 \\
    P(n) \cdot x(n)
    & \text{if }x(n) \geq 1
\end{cases}
\\~\\

y(n) = y(n - 1) + \Delta y(n)
\\~\\

x_0(n + 1) = x(n) - \Delta y(n)

```

## Software Name Mappings

Because of naming restrictions imposed by the Julia language and Julia coding style, I cannot use the parameter, variable and function names from this summary for the parameter, variable and function names in the program. So, I have mapped names in the summary to names in the program while attempting to keep them consistent.

### Parameter Name Mappings

- ``E_0 \Rightarrow`` e\_0
- ``E_1 \Rightarrow`` e\_1
- ``A_0 \Rightarrow`` a\_0
- ``A_1 \Rightarrow`` a\_1
- ``\Theta_f \Rightarrow`` theta\_f
- ``F \Rightarrow`` f

### Variable Name Mappings

- ``\Theta_n \Rightarrow`` theta\_n

### Equation Name Mappings

- ``k_0(n) \Rightarrow`` k\_0\_n
- ``k_1(n) \Rightarrow`` k\_1\_n
- ``x_s(n) \Rightarrow`` x\_s\_n
- ``x(n) \Rightarrow`` x\_n
- ``p(n) \Rightarrow`` p\_n
- ``\Delta y(n) \Rightarrow`` delta\_y\_n
- ``y(n) \Rightarrow`` y\_n
- ``y(n - 1) \Rightarrow`` y\_nMinus1
- ``x_0(n) \Rightarrow`` x\_0\_n
- ``x_0(n + 1) \Rightarrow`` x\_0\_nPlus1

## Appendix

For reference, I have included the equations A1, A2, A3 and A4 from the ["computer simulation"](https://doi.org/10.1016/S0022-5193(87)80237-0) paper.

```math
\tag*{A1}

E_1
=
\frac
{E_0 - E_1}
{
    (e^{(E_1 - E_0) \cdot q} - 1)
    \cdot
    ln(1 - e^{(E_0 - E_1) \cdot q})
}

```

```math
\tag*{A2}

k_1(\Theta^*) =
- \frac
{
    ln(1 - e^{(E_0 - E_1) \cdot q})
}
{
    \tau(\Theta^*)
}

```

```math
\tag*{A3}

A_0
= A_1 \cdot e^{(E_0 - E_1) / \Theta_c}

```

```math
\tag*{A4}

\frac
{
    e^{(E_1 - E_0) / \Theta_c} -
    e^{(E_1 - E_0) / \Theta_1}
}
{
    e^{(E_1 - E_0) / \Theta_2} -
    e^{(E_1 - E_0) / \Theta_1}
}
=
\frac
{
    1 -
    e^{
        - k_1(\Theta_2) \cdot
        (1 - \eta) \cdot
        \pi_c
    }
}
{
    1 -
    e^{
        - (
            k_1(\Theta_1) \cdot \eta +
            k_1(\Theta_2) \cdot (1 - \eta)
        ) \cdot \pi_c
    }
}

```

where

```math

q = \frac{1}{\Theta^*} - \frac{1}{\Theta_c}

```

---

Last Reviewed on 19 February 2021
