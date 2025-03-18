---
geometry:
  - margin=2cm
---

# ME599 Homework 4 - Akshat Dubey

## Problem 1

We have a system characterized by

- Input: $V(t)$ Voltage pulse imputed on the nozzle system
- System: $\mathcal{G}$, the nozzle system
- Output: $P(t)$ pressure wave at the nozzle

The system $\mathcal{G}$ is not available to us, it is a black box. We can only give it inputs and observe the outputs. In this problem we are trying to get the system to output a specific pressure waveform, and hence we need to implement a controller that can converge to a specific input voltage waveform that produces the desired pressure waveform.

### Problem 1.a

To check if the input-output operator $\mathcal{G}$ is linear, we can check if the system satisfies the superposition principle. This can be done by checking if the following equation holds true for all $V_1(t)$ and $V_2(t)$ and $a_1$ and $a_2$:

$$
\mathcal{G}(a_1 V_1(t) + a_2 V_2(t)) = a_1 \mathcal{G}(V_1(t)) + a_2 \mathcal{G}(V_2(t))
$$

For this, we first generate the two voltages $V_1(t)$ and $V_2(t)$ and set $a_1=-0.23$ and $a_2=1.14$ (chosen randomly).

![Input Voltage Waveforms](figs/hw4p1a_volts.svg)

Then we pass them through the operator $\mathcal{G}$ and plot the output pressure waveforms. Let

$$
\begin{aligned}
P_1(t) &= \mathcal{G}(V_1(t)) \\
P_2(t) &= \mathcal{G}(V_2(t)) \\
P_{12}(t) &= \mathcal{G}(a_1 V_1(t) + a_2 V_2(t)) \\
P_{a}(t) &= a_1 P_1(t) + a_2 P_2(t)
\end{aligned}
$$

![Output Pressure Waveforms](figs/hw4p1a_press.svg)

In this plot, we can see that the pressure waveform for $P_{12}(t)$ (the output of the system for the combined input) is the same as the pressure waveform for $P_a(t)$ (the output of the system for the individual inputs scaled by $a_1$ and $a_2$). This means that the system satisfies the superposition principle and is hence $\mathcal{G}$ is linear.

## Problem 1.b
