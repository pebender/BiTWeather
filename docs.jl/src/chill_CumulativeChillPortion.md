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

The model predicts there is an optimum temperature at which chill accumulates most quickly. This is not unexpected. Previously observation derived models have been moving in this direction. First, the developers of the [Cumulative Chill Hour](chill_TemperatureRange.md) model observed there is a temperature above which there is no significant chill accumulation. Then they observed there is a temperature below which there is no significant chill accumulation. Later, the developers of the [Cumulative Chill Unit](chill_CumulativeChillUnit.md) model observed that chill accumulates less quickly when the temperature is near the edge of lower and upper temperature thresholds and more quickly when it is in the middle of the temperature range. We will call this optimum temperature $\Theta^*$ and time between transfer of PDBF to DBF at this optimum temperature $\tau^*$.

The model predicts there is a critical temperature above which no chill accumulates. This is not unexpected. The developers of both the [Cumulative Chill Hour](chill_TemperatureRange.md) and [Cumulative Chill Unit](chill_CumulativeChillUnit.md) models observed this behavior. We will call this temperature $\Theta_c$

The model predicts that when the temperature cycles between temperatures that are above and below the optimum temperature, chill can accumulate more quickly than at the optimum temperature. This is unexpected. People developing chill models had not observed this behavior until after it was predicted by the math. However, this lack of prior observation is not unexpected. It can be difficult to recognize short term dynamics of a system, especially what the short term dynamics are counterintuitive. We will call the higher temperature $\Theta_1$, the lower temperature $\Theta_2$, the period of the cycle $\pi_c$ and the relative time spent at the higher and lower temperatures $\eta$.

### Hidden Parameters

Because of the creation and destruction of PDBF are each modeled an [Arrhenius equation](https://en.wikipedia.org/wiki/Arrhenius_equation), the model needs the four hidden parameters creation activation energy $E_0$, the creation rate $A_0$, the destruction activation $E_1$ and destruction rate $A_1$. We can derive these hidden parameters from the observable parameters using equations A1, A2, A3 and A4 from the ["computer simulation"](https://doi.org/10.1016/S0022-5193(87)80237-0) paper. I included these for equations in the [Appendix](#Appendix) in case anyone needs to determine the hidden parameters for their own set of observable parameters.

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

The discrete implementation holds the temperature constant for a time interval $n$. After updating the equations using this temperature, the implementation uses the updated values as the initial values for the next time interval $n + 1$ and repeats the process.

For this discrete implementation, PDBF is given by

```math

x(n) = x_s(n) - (x_s(n) - x_0(n)) \cdot e^{-k_1(n)}

```

where

```math

x_s(n) = \frac{k_0(n)}{k_1(n)}

```

and

```math

k_0(n) = A_0 \cdot e^{- \frac{E_0}{\Theta_n}}
\space,\space
k_1(n) = A_1 \cdot e^{- \frac{E_1}{\Theta_n}}

```

 $x(n)$ is the PDBF after the time interval $n$ but before any transfer of PDBF to DBF. $x_0(n)$ is the PDBF at the end of the previous time interval after any transfer of PDBF to DBF. $x_s(n)$ is the steady state value of $x(n)$ were the temperature constant for all values of $n$. $k_0(n)$ and $k_1(n)$ are the rates of PDBF creation and destruction during the time interval, and $\Theta_n$ is the temperature during the time interval.

When $x(n) = 1$, there is a probability that the PDBF will transfer to DBF. This probability is given by the sigmoidal function

```math

p(n) = \frac{e^{4 \cdot F \cdot (\frac{\Theta_f}{\Theta_n}) \cdot (\Theta_n - \Theta_f)}}{1 + e^{4 \cdot F \cdot (\frac{\Theta_f}{\Theta_n}) \cdot (\Theta_n - \Theta_f)}}
\space,\space
\Theta_f = 277 \space \text{K}
\space,\space
F = 0.4 \space K^{-1}

```

where $\Theta_f$ is the transition temperature and $F$ is the slope at the transition temperature. $\Theta_f$ and $F$ are chosen based on observation.

Rather than flip a coin with bias $p(n)$ each time $x(n) = 1$, we transfer $p(n)$ amount of $x(n)$ to $y(n)$ each time $x(n) = 1$. While not correct for any giving instance of $x(n) = 1$, it is approximately correct after many occurrences of the same value of $\Theta_n$ and has the advantage of making the $x(n)$ and $y(n)$ deterministic for a given sequence of $\Theta_n$.

Under these assumptions, the transfer of PDBF to DBF is given by $\Delta y(n)$, DPF is given by $y(n)$ and the initial PDBF for the next time interval is given by $x_0(n + 1)$. At the start of the simulation, $x_0(n)$ and $y(n)$ with zero.

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

E_1
=
\frac
    {E_0 - E_1}
    {(e^{(E_1 - E_0) \cdot q} - 1) \cdot
    ln(1 - e^{(E_0 - E_1) \cdot q})}
\\~\\

k_1(\Theta^*) =
- \frac
    {
        ln(1 - e^{(E_0 - E_1) \cdot q})
    }
    {
        \tau(\Theta^*)
    }
\\~\\

A_0
= A_1 \cdot e^{(E_0 - E_1) / \Theta_c}
\\~\\

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

### Equations

Notice that only the third equation depends on ``A_0``. Therefore, we have three not four interdependent non-linear equations we need to solve. These equations are

```math

F_1(A_1, E_1, E_x)
=
(f(E_x, \Theta_{*|c}) - 1)
\cdot
ln(1 - f(- E_x, \Theta_{*|c}))
+
\frac{E_x}{E_1}
=
0
\\~\\

F_2(A_1, E_1, E_x)
=
\frac{1}{A_1
\cdot
\tau^*}
f(E_1, \Theta^*)
\cdot
ln(1 - f(- E_x, \Theta_{*|c}))
+
1
=
0
\\~\\

F_3(A_1, E_1, E_x)
=
\frac
{f(E_x, \Theta_2) - f(E_x, \Theta_c)}
{f(E_x, \Theta_c) - f(E_x, \Theta_1)}
-
\frac{1 - g_1 \cdot g_2}{1 - g_2}
=
0

```

where

```math

f(E, \Theta) = e^{E / \Theta}
\quad,\quad
f(-E, \Theta) = f(E, - \Theta) = \frac{1}{f(E, \Theta)}
\\~\\
g(\alpha, A, f(-E, \Theta))
=
e^{- \alpha \cdot A \cdot f(-E, \Theta)}
=
e^{- \alpha \cdot A \cdot e^{-E / \Theta}}
\\~\\

A_0 = A_1 \cdot f(E_x, \Theta_c)
\quad,\quad
E_x = E_1 - E_0
\quad,\quad
\frac{1}{\Theta_{*|c}} = \frac{1}{\Theta^*} - \frac{1}{\Theta_c}
\\~\\

f_1 = f(- E_1, \Theta_1)
\quad,\quad
f_2 = f(- E_1, \Theta_2)
\\~\\

g_1 = g(\pi_c \cdot \eta, A_1, f_1)
\quad,\quad
g_2 = g(\pi_c \cdot (1 - \eta), A_1, f_2)

```

### Partial Derivatives

Unfortunately, the equations do not have a closed form solution. However, if we have the partial derivatives, then we can form the Jacobian matrix and solve the equations numerically. You can skip past the details of the partial derivative calculation and go right to [solving](#solving).

#### Partial Derivatives Common to All Functions

```math

\frac{\partial f(E, \Theta)}{\partial E} = \frac{1}{\Theta} \cdot f(E, \Theta)

\\~\\

\frac{\partial f_1}{\partial E_1} = - \frac{1}{\Theta_1} \cdot f_1
\quad,\quad
\frac{\partial f_2}{\partial E_1} = - \frac{1}{\Theta_2} \cdot f_2

\\~\\

\frac{\partial g_1}{\partial A_1} =
- \pi_c \cdot \eta
\cdot
g_1 \cdot f_1
\quad,\quad
\frac{\partial g_2}{\partial A_1} =
- \pi_c \cdot (\eta - 1) 
\cdot
g_2 \cdot f_2

\\~\\

\frac{\partial g_1}{\partial E_1} =
\frac{\pi_c \cdot \eta \cdot A_1}{\Theta_1}
\cdot
g_1 \cdot f_1
\quad,\quad
\frac{\partial g_2}{\partial E_1} =
\frac{\pi_c \cdot (\eta - 1) \cdot A_1}{\Theta_1}
\cdot
g_2 \cdot f_2

\\~\\

\frac{\partial (1 - g_2)^{-1}}{\partial A_1}
=
- \pi_c \cdot (\eta - 1)
\cdot
\frac{g_2 \cdot f_2}{(1 - g_2)^2}

\\~\\

\frac{\partial (1 - g_2)^{-1}}{\partial E_1}
=
\frac{\pi_c \cdot (\eta - 1) \cdot A_1}{\Theta_1}
\cdot
\frac{1}{(1 - g_2)^2}

\\~\\

\frac{\partial ln(1 - f(-E_x, \Theta_{*|c})}{\partial E_x} =
\frac{1}{\Theta_{*|c}}
\cdot
\frac{f(- E_x, \Theta_{*|c})}{1 - f(- E_x, \Theta_{*|c})}
=
\frac{1}{\Theta_{*|c}}
\cdot
\frac{1}{f(E_x, \Theta_{*|c}) - 1}

\\~\\

\frac{\partial (f(E_x, \Theta_{*|c}) - 1)^{-1}}{\partial E_x} =
- \frac{1}{\Theta_{*|c}}
\cdot
\frac{f(E_x, \Theta_{*|c})}{(f(E_x, \Theta_{*|c}) - 1)^2}

```

#### Partial Derivatives of ``F_1``

```math

\frac{\partial F_1}{\partial A_1}
=
0
\\~\\~\\

\frac{\partial F_1}{\partial E_1}
=
- \frac{E_x}{E_1^2}
\\~\\~\\

\frac{\partial F_1}{\partial E_x}
= \\~\\
\frac{1}{\Theta_{*|c}}
\cdot
f(E_x, \Theta_{*|c})
\cdot
ln(1 - f(- E_x, \Theta_{*|c}))
+ \\~\\
(f(E_1, \Theta_{*|c}) - 1)
\cdot
\frac{1}{\Theta_{*|c}}
\cdot
\frac{1}{1 - f(- E_x, \Theta_{c|*})}
+
\frac{1}{E_1}

= \\~\\

\frac{1}{\Theta_{*|c}}
\cdot
f(E_x, \Theta_{*|c})
\cdot
(
    -\frac{E_x}{E_1}
    \cdot
    \frac{1}{f(E_x, \Theta_{*|c}) - 1}
)
+
\frac{f(E_x, \Theta_{*|c})}{\Theta_{*|c}}
+
\frac{1}{E_1}
= \\~\\
\frac{f(E_x, \Theta_{*|c})}{\Theta_{*|c}}
\cdot
(
    1
    -
    \frac{E_x}{E_1}
    \cdot
    \frac{1}{f(E_x, \Theta_{*|c}) - 1}
)
+
\frac{1}{E_1}

```

#### Partial Derivatives of ``F_2``

```math

\frac{\partial F_2}{\partial A_1}
=
- \frac{1}{A_1}

\\~\\~\\

\frac{\partial F_2}{\partial E_1}
= 
\frac{1}{\Theta^*}
\cdot
\frac{1}{A_1 \cdot \tau^*}
\cdot
f(E_1, \Theta^*)
\cdot
ln(1 - f(- E_x, \Theta_{*|c}))
=
- \frac{1}{\Theta^*}
\\~\\~\\

\frac{\partial F_2}{\partial E_x}
=
\frac{1}{A_1 \cdot \tau^*}
\cdot
f(E_1, \Theta^* \cdot )
\cdot
\frac{1}{\Theta_{*|c}}
\cdot
\frac{1}{f(E_x, \Theta_{*|c}) - 1}
= \\~\\
\frac{1}{A_1 \cdot \tau^* \cdot \Theta_{*|c}}
\cdot
\frac{f(E_1, \Theta^*)}{f(E_x, \Theta_{*|c}) - 1}

```

#### Partial Derivatives of ``F_3``

```math

\\~\\

\frac{\partial F_3}{\partial A_1}
= \\~\\

\frac{1}{1 - g_2}
\cdot
(
    - g_2
    \cdot
    (
        - \pi_c \cdot \eta
        \cdot
        g_1 \cdot f_1
    )
)
\\~\\
+
\frac{1}{1 - g_2}
\cdot
(
    - g_1
    \cdot
    (
        - \pi_c \cdot (\eta - 1)
        \cdot
        g_2 \cdot f_2
    )
)
\\~\\
+
(1 - g_1 \cdot g_2)
\cdot
(
    - \pi_c \cdot (\eta - 1)
    \cdot
    \frac{g_2 \cdot f_2}{(1 - g_2)^2}
)
= \\~\\

\pi_c \cdot \eta
\cdot
\frac{g_2 \cdot g_1 \cdot f_1}{1 - g_2}
\\~\\
\pi_c \cdot (\eta - 1)
\cdot
\frac{g_1 \cdot g_2 \cdot f_2}{1 - g_2}
\\~\\
- \pi_c \cdot (\eta - 1)
\cdot
-\frac{(1 - g_1 \cdot g_2) \cdot g_2 \cdot f_2}{(1 - g_2)^2}
= \\~\\

\pi_c \cdot \eta
\cdot
\frac{g_2 \cdot g_1 \cdot f_1}{1 - g_2} +
\\~\\
\frac{\pi_c \cdot (\eta - 1)}{\Theta_1}
\cdot
\frac
{(g_2 \cdot f_2 - g_1 \cdot g_2 \cdot g_2 \cdot f_2)
-
(g_1 \cdot g_2 \cdot f_2 - g_2 \cdot g_1 \cdot g_2 \cdot f_2)}
{(1 - g_2)^2}
= \\~\\

\pi_c \cdot \eta
\cdot
\frac{g_2 \cdot g_1 \cdot f_1}{1 - g_2} +
\pi_c \cdot (\eta - 1)
\cdot
\frac
{(1 - g_1) \cdot g_2 \cdot f_2}
{(1 - g_2)^2}
\\~\\~\\

\frac{\partial F_3}{\partial E_1}
= \\~\\
\frac{1}{1 - g_2}
\cdot
(
    - g_2
    \cdot
    (
        \frac{\pi_c \cdot \eta \cdot A_1}{\Theta_1}
        \cdot
        g_1 \cdot f_1
    )
)
\\~\\
+
\frac{1}{1 - g_2}
\cdot
(
    - g_1
    \cdot
    (
        \frac{\pi_c \cdot (\eta - 1) \cdot A_1}{\Theta_2}
        \cdot
        g_2 \cdot f_2
    )
)
\\~\\
+
(1 - g_1 \cdot g_2)
\cdot
(
    \frac{\pi_c \cdot (\eta - 1) \cdot A_1}{\Theta_2}
    \cdot
    \frac{g_2 \cdot f_2}{(1 - g_2)^2}
)
= \\~\\

- \frac{\pi_c \cdot \eta \cdot A_1}{\Theta_1}
\cdot
\frac{g_2 \cdot g_1 \cdot f_1}{1 - g_2}
\cdot
\\~\\
- \frac{\pi_c \cdot (\eta - 1) \cdot A_1}{\Theta_2}
\cdot
\frac{g_1 \cdot g_2 \cdot f_2}{1 - g_2}
\\~\\
+ \frac{\pi_c \cdot (\eta - 1) \cdot A_1}{\Theta_2}
\cdot
\frac{(1 - g_1 \cdot g_2) \cdot g_2 \cdot f_2}{(1 - g_2)^2}
= \\~\\

- \frac{\pi_c \cdot \eta \cdot A_1}{\Theta_1}
\cdot
\frac{g_2 \cdot g_1 \cdot f_1}{1 - g_2}
\\~\\
- \frac{\pi_c \cdot (\eta - 1) \cdot A_1}{\Theta_2}
\cdot
\frac
{(g_2 \cdot f_2 - g_1 \cdot g_2 \cdot g_2 \cdot f_2)
-
(g_1 \cdot g_2 \cdot f_2 - g_2 \cdot g_1 \cdot g_2 \cdot f_2)}
{(1 - g_2)^2}
= \\~\\

- \frac{\pi_c \cdot \eta \cdot A_1}{\Theta_1}
\cdot
\frac{g_2 \cdot g_1 \cdot f_1}{1 - g_2} -
\frac{\pi_c \cdot (1 - \eta) \cdot A_1}{\Theta_2}
\cdot
\frac
{(1 - g_1) \cdot g_2 \cdot f_2}
{(1 - g_2)^2}
\\~\\~\\

\frac{\partial F_3}{\partial E_x}
= \\~\\

\frac{1}{f(E_x, \Theta_1) - f(E_x, \Theta_c)}
\cdot
(
    \frac{1}{\Theta_1} \cdot f(E_x, \Theta_1)
    -
    \frac{1}{\Theta_2} \cdot f(E_x, \Theta_2)
)
+ \\~\\
(f(E_x, \Theta_1) - f(E_x, \Theta_2))
\cdot
\frac{-1}{(f(E_x, \Theta_1) - f(E_x, \Theta_c))^2}
\cdot
(
    \frac{1}{\Theta_1} \cdot f(E_x, \Theta_1) 
    -
    \frac{1}{\Theta_c} \cdot f(E_x, \Theta_c) 
)
= \\~\\

\frac
{
    \frac{1}{\Theta_1} \cdot f(E_x, \Theta_1)
    -
    \frac{1}{\Theta_2} \cdot f(E_x, \Theta_2)
}
{
    f(E_x, \Theta_1) - f(E_x, \Theta_c)
}
- \\~\\
\frac{
    (
        f(E_x, \Theta_2)
        -
        f(E_x, \Theta_1)
    )
    \cdot
    (
        \frac{1}{\Theta_c} \cdot f(E_x, \Theta_c)
        -
        \frac{1}{\Theta_1} \cdot f(E_x, \Theta_1)
    )
}
{
    (f(E_x, \Theta_c) - f(E_x, \Theta_1))^2
}
= \\~\\

\frac
{
    (
        \frac{1}{\Theta_2} \cdot f(E_x, \Theta_2)
        -
        \frac{1}{\Theta_1} \cdot f(E_x, \Theta_1)
    )
    \cdot
    (
        f(E_x, \Theta_c)
        -
        f(E_x, \Theta_1)
    )
}
{
    (f(E_x, \Theta_c) - f(E_x, \Theta_1))^2
}
- \\~\\
\frac{
    (
        f(E_x, \Theta_2)
        -
        f(E_x, \Theta_1)
    )
    \cdot
    (
        \frac{1}{\Theta_c} \cdot f(E_x, \Theta_c)
        -
        \frac{1}{\Theta_1} \cdot f(E_x, \Theta_1)
    )
}
{
    (f(E_x, \Theta_c) - f(E_x, \Theta_1))^2
}
= \\~\\

\frac
{
    \frac{f(E_x, \Theta_2) \cdot f(E_x, \Theta_c)}{\Theta_2}
    -
    \frac{f(E_x, \Theta_2) \cdot f(E_x, \Theta_1)}{\Theta_2}
    -
    \frac{f(E_x, \Theta_1) \cdot f(E_x, \Theta_c)}{\Theta_1}
    +
    \frac{f(E_x, \Theta_1) \cdot f(E_x, \Theta_1)}{\Theta_1}
}
{
    (f(E_x, \Theta_c) - f(E_x, \Theta_1))^2
}
- \\~\\
\frac{
    \frac{f(E_x, \Theta_2) \cdot f(E_x, \Theta_c)}{\Theta_c}
    -
    \frac{f(E_x, \Theta_2) \cdot f(E_x, \Theta_1)}{\Theta_1}
    -
    \frac{f(E_x, \Theta_1) \cdot f(E_x, \Theta_c)}{\Theta_c}
    +
    \frac{f(E_x, \Theta_1) \cdot f(E_x, \Theta_1)}{\Theta_1}

}
{
    (f(E_x, \Theta_c) - f(E_x, \Theta_1))^2
}

= \\~\\

\frac
{
    f(E_x, \Theta_2) \cdot f(E_x, \Theta_c)
    \cdot
    (\frac{1}{\Theta_2} - \frac{1}{\Theta_c})
    +
    f(E_x, \Theta_c) \cdot f(E_x, \Theta_1)
    \cdot
    (\frac{1}{\Theta_c} - \frac{1}{\Theta_1})
}
{(f(E_x, \Theta_c) - f(E_x, \Theta_1))^2}
- \\~\\
\frac
{
    f(E_x, \Theta_2) \cdot f(E_x, \Theta_1)
    \cdot
    (\frac{1}{\Theta_2} - \frac{1}{\Theta_1})

}
{(f(E_x, \Theta_c) - f(E_x, \Theta_1))^2}

```

### Solving

There are many software packages that will calculate the values of an input vector ``\hat{x}`` that solve the vector of functions ``\hat{F}(\hat{x})`` as long as we have the Jacobian matrix ``\hat{J}(\hat{F}, \hat{x})``. I have chosen to use [NLSolve.jl](https://github.com/JuliaNLSolvers/NLsolve.jl).

We have

```math

\hat{x} =
\begin{bmatrix}
A_1
\\~\\
E_1
\\~\\
E_x
\end{bmatrix}
\quad,\quad

\hat{F}(\hat{x}) =
\begin{bmatrix}
F_1
\\~\\
F_2
\\~\\
F_3
\end{bmatrix}
\quad,\quad

\hat{J}(\hat{F}, \hat{x}) =
\begin{bmatrix}
\frac{\partial F_1}{\partial A_1}
&&
\frac{\partial F_1}{\partial E_1}
&&
\frac{\partial F_1}{\partial E_x}
\\~\\
\frac{\partial F_2}{\partial A_1}
&&
\frac{\partial F_2}{\partial E_1}
&&
\frac{\partial F_2}{\partial E_x}
\\~\\
\frac{\partial F_3}{\partial A_1}
&&
\frac{\partial F_3}{\partial E_1}
&&
\frac{\partial F_3}{\partial E_x}
\end{bmatrix}

```

where the functions are

```math

F_1(A_1, E_1, E_x)
=
(f(E_x, \Theta_{*|c}) - 1)
\cdot
ln(1 - f(- E_x, \Theta_{*|c}))
+
\frac{E_x}{E_1}
=
0
\\~\\

F_2(A_1, E_1, E_x)
=
\frac{1}{A_1 \cdot \tau^*}
f(E_1, \Theta^*)
\cdot
ln(1 - f(- E_x, \Theta_{*|c}))
+
1
=
0
\\~\\

F_3(A_1, E_1, E_x)
=
\frac
{f(E_x, \Theta_1) - f(E_x, \Theta_2)}
{f(E_x, \Theta_1) - f(E_x, \Theta_c)}
-
\frac{1 - g_1 \cdot g_2}{1 - g_2}
=
0

```

and the partial derivatives are

```math

\frac{\partial F_1}{\partial A_1} = 0
\\~\\

\frac{\partial F_1}{\partial E_1} = - \frac{E_x}{E_1^2}
\\~\\

\frac{\partial F_1}{\partial E_x}
=
\frac{f(E_x, \Theta_{*|c})}{\Theta_{*|c}}
\cdot
(
    1
    -
    \frac{E_x}{E_1}
    \cdot
    \frac{1}{f(E_x, \Theta_{*|c}) - 1}
)
+
\frac{1}{E_1}

\\~\\

\frac{\partial F_2}{\partial A_1}
=
- \frac{1}{A_1}
\\~\\

\frac{\partial F_2}{\partial E_1}
=
- \frac{1}{\Theta^*}
\\~\\

\frac{\partial F_2}{\partial E_x}
=
\frac{1}{A_1 \cdot \tau^* \cdot \Theta_{*|c}}
\cdot
\frac{f(E_1, \Theta^*)}{f(E_x, \Theta_{*|c}) - 1}

\\~\\

\frac{\partial F_3}{\partial A_1}
=
\pi_c \cdot \eta
\cdot
\frac{g_2 \cdot g_1 \cdot f_1}{1 - g_2} +
\pi_c \cdot (\eta - 1)
\cdot
\frac
{(1 - g_1) \cdot g_2 \cdot f_2}
{(1 - g_2)^2}
\\~\\~\\

\frac{\partial F_3}{\partial E_1}
=
- \frac{\pi_c \cdot \eta \cdot A_1}{\Theta_1}
\cdot
\frac{g_2 \cdot g_1 \cdot f_1}{1 - g_2} -
\frac{\pi_c \cdot (1 - \eta) \cdot A_1}{\Theta_2}
\cdot
\frac
{(1 - g_1) \cdot g_2 \cdot f_2}
{(1 - g_2)^2}
\\~\\

\frac{\partial F_3}{\partial E_x}
= \\~\\
\frac
{
    f(E_x, \Theta_2) \cdot f(E_x, \Theta_c)
    \cdot
    (\frac{1}{\Theta_2} - \frac{1}{\Theta_c})
    +
    f(E_x, \Theta_c) \cdot f(E_x, \Theta_1)
    \cdot
    (\frac{1}{\Theta_c} - \frac{1}{\Theta_1})
}
{(f(E_x, \Theta_c) - f(E_x, \Theta_1))^2}
- \\~\\
\frac
{
    f(E_x, \Theta_2) \cdot f(E_x, \Theta_1)
    \cdot
    (\frac{1}{\Theta_2} - \frac{1}{\Theta_1})

}
{(f(E_x, \Theta_c) - f(E_x, \Theta_1))^2}

```

and where

```math

\frac{1}{\Theta_{*|c}} = \frac{1}{\Theta^*} - \frac{1}{\Theta_c}
\\~\\

f(E, \Theta) = e^{E / \Theta}
\\~\\
g(\alpha, A, f(-E, \Theta))
=
e^{- \alpha \cdot A \cdot f(-E, \Theta)}
=
e^{- \alpha \cdot A \cdot e^{-E / \Theta}}
\\~\\

f_1 = f(- E_1, \Theta_1)
\quad,\quad
f_2 = f(- E_1, \Theta_2)
\\~\\

g_1 = g(\pi_c \cdot \eta, A_1, f_1)
\quad,\quad
g_2 = g(\pi_c \cdot (1 - \eta), A_1, f_2)

```

In order to numerically solve for ``A_1``, ``E_1`` and ``E_x``, we need initial values for each of them. I would use the values in this memo as the initial values, until you find they do not work for your combination of values.
