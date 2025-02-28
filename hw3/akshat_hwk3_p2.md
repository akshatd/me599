---
geometry:
  - margin=2cm
---

## Problem 2.a

![Circuit Diagram](hw3p2_circuit.jpg)

For the given motor with a point mass attached, we are given:

- $R_m = 3.5 \Omega$ (motor resistance)
- $K_b = 0.1 Vs/rad$ (motor back EMF constant)
- $K_t = 0.5K_b = 0.05 Nm/A$ (motor torque constant)
- $L_m = 0 H$ (motor inductance)
- $m_p = 0.04 kg$ (point mass)
- $L_p = 0.1 m$ (distance from motor to point mass)
- $I_p = m_p(L_p)^2 = 0.0004 kgm^2$ (moment of inertia of point mass)
- $B_m = 0.000008 Nms/rad$ (motor viscous friction constant)
- $g = 9.81 m/s^2$ (acceleration due to gravity)

Let

- $\theta$ : angle of the motor shaft
- $V$ : input voltage
- $i$ : motor current
- $T_m$ : net torque on the motor shaft

We can derive the following equation for the voltage in the circuit

- Voltage drop due to inductance: $L_m\frac{di}{dt}$
- Voltage drop across the motor: $R_mi$
- Voltage drop due to back EMF: $K_b\dot{\theta}$

$$
\begin{aligned}
\implies V &= L_m\frac{di}{dt} + R_mi + K_b\dot{\theta} \\
\text{Since } L_m = 0, \text{ we have } V &= R_mi + K_b\dot{\theta} \\
i &= \frac{V - K_b\dot{\theta}}{R_m} \quad (1)
\end{aligned}
$$

We can also derive the following equation for the torque on the point mass

- Torque due to the motor: $K_ti$
- Frictional torque: $B_m\dot{\theta}$
- Force on mass due to gravity(weight): $m_pg$
- Perpendicular distance of the force of weight from the motor shaft: $L_p cos(\theta)$

$$
\begin{aligned}
\implies T_m &= K_ti - B_m\dot{\theta} - m_pgL_p cos(\theta) \\
\text{Substituting for } i \text{ from } (1),& \text{ we have} \\
T_m &= K_t\left(\frac{V - K_b\dot{\theta}}{R_m}\right) - B_m\dot{\theta} - m_pgL_p cos(\theta) \\
&= \frac{K_tV}{R_m} - \frac{K_tK_b\dot{\theta}}{R_m} - B_m\dot{\theta} - m_pgL_p cos(\theta) \\
&= \frac{K_tV}{R_m} - \left(\frac{K_tK_b}{R_m} + B_m\right)\dot{\theta} - m_pgL_p cos(\theta) \quad (2)
\end{aligned}
$$

Finally, using the equation of angular acceleration and torque, we have

$$
\begin{aligned}
T_m &= I_p\ddot{\theta} \\
\text{Substituting for } T_m \text{ from } (2),& \text{ we have} \\
I_p\ddot{\theta} &= \frac{K_tV}{R_m} - \left(\frac{K_tK_b}{R_m} + B_m\right)\dot{\theta} - m_pgL_p cos(\theta) \\
\ddot{\theta} &= \frac{K_tV}{I_pR_m} - \left(\frac{K_tK_b}{R_m} + B_m\right)\frac{\dot{\theta}}{I_p} - \frac{m_pgL_p}{I_p} cos(\theta) \quad (3)
\end{aligned}
$$

For our state space model, we have the following state variables:

$$
x_1 = \theta \quad x_2 = \dot{\theta} \quad u = V
$$

Where we observe only the output angle $\theta$ of the motor shaft.
Which gives us the following state space equations:

$$
\begin{aligned}
\dot{x_1} &= x_2 \\
\dot{x_2} &= \frac{K_tu}{I_pR_m} - \left(\frac{K_tK_b}{R_m} + B_m\right)\frac{x_2}{I_p} - \frac{m_pgL_p}{I_p} cos(x_1) \\
y &= x_1
\end{aligned}
$$

## Problem 2.b

To find the equilibrium points, we set $u=0$ and $\dot{x_1} = 0$:

$$
\begin{aligned}
0 &= x_2 \\
\implies x_2 &= 0 \\
\end{aligned}
$$

similarly, we set $\dot{x_2} = 0$:

$$
\begin{aligned}
0 &= \frac{K_tu}{I_pR_m} - \left(\frac{K_tK_b}{R_m} + B_m\right)\frac{x_2}{I_p} - \frac{m_pgL_p}{I_p} cos(x_1) \\
\text{Since } x_2 &= 0 \text{ and } u=0, \text{ we have} \\
0 &= \frac{K_t0}{I_pR_m} - \left(\frac{K_tK_b}{R_m} + B_m\right)\frac{0}{I_p} - \frac{m_pgL_p}{I_p} cos(x_1) \\
0 &= - \frac{m_pgL_p}{I_p} cos(x_1) \\
\implies cos(x_1) &= 0 \\
\end{aligned}
$$

Hence, the equilibrium points are

$$
\begin{aligned}
x_{1eq} &= \frac{\pi}{2} + n\pi \quad n \in \mathbb{Z} \\
x_{2eq} &= 0 \\
u_{eq} &= 0
\end{aligned}
$$

To comment on the stability of the points, we need to linearize the system around the equilibrium points and check the eigenvalues of the system. First, we need the Jacobian matrix $\nabla_x f$ where:

$$
\begin{aligned}
\boldsymbol{x} &= \begin{bmatrix} x_1 \\ x_2 \end{bmatrix} \\
f &= \begin{bmatrix} x_2 \\ \frac{K_tu}{I_pR_m} - \left(\frac{K_tK_b}{R_m} + B_m\right)\frac{x_2}{I_p} - \frac{m_pgL_p}{I_p} cos(x_1) \end{bmatrix} \\
\end{aligned}
$$

Then, the Jacobian matrix is:

$$
\begin{aligned}
\nabla_x f &= \begin{bmatrix} \frac{\partial f_1}{\partial x_1} & \frac{\partial f_1}{\partial x_2} \\ \frac{\partial f_2}{\partial x_1} & \frac{\partial f_2}{\partial x_2} \end{bmatrix} \\
\frac{\partial f_1}{\partial x_1} &= 0 \\
\frac{\partial f_1}{\partial x_2} &= 1 \\
\frac{\partial f_2}{\partial x_1} &= \frac{m_pgL_p}{I_p} sin(x_1) \\
\frac{\partial f_2}{\partial x_2} &= -\left(\frac{K_tK_b}{R_m} + B_m\right)\frac{1}{I_p} \\
\implies \nabla_x f &= \begin{bmatrix} 0 & 1 \\ \frac{m_pgL_p}{I_p} sin(x_1) & -\left(\frac{K_tK_b}{R_m} + B_m\right)\frac{1}{I_p} \end{bmatrix} \\
\end{aligned}
$$

Linearizing around the equilibrium points $x_{1eq}, x_{2eq}, u_{eq}$, we notice that we only have 2 choices for $x_{1eq}$ at $\pi/2$ and $3\pi/2$.

For $x_{1eq} = \pi/2$, we have:

$$
\begin{aligned}
A_1 &= \nabla_x f \Big|_{x_{1eq} = \pi/2, x_{2eq} = 0, u_{eq} = 0} \\
&= \begin{bmatrix} 0 & 1 \\ \frac{m_pgL_p}{I_p} & -\left(\frac{K_tK_b}{R_m} + B_m\right)\frac{1}{I_p} \end{bmatrix} \\
\end{aligned}
$$

To check stability, we need to find the eigenvalues of the matrix $A_1$

- 7.84
- -12.51

Since we have an eigenvalue with a positive real part, the equilibrium point is unstable.

For $x_{1eq} = 3\pi/2$, we have:

$$
\begin{aligned}
A_2 &= \nabla_x f \Big|_{x_{1eq} = 3\pi/2, x_{2eq} = 0, u_{eq} = 0} \\
&= \begin{bmatrix} 0 & 1 \\ -\frac{m_pgL_p}{I_p} & -\left(\frac{K_tK_b}{R_m} + B_m\right)\frac{1}{I_p} \end{bmatrix} \\
\end{aligned}
$$

To check stability, we need to find the eigenvalues of the matrix $A_2$

- -2.33
- -2.33

Since we have eigenvalues with negative real parts, the equilibrium point is stable. In general, we can say that the equilibrium points

$$
\begin{aligned}
\boldsymbol{x}_{eq} &= \begin{bmatrix} \pi/2 + n\pi \\ 0 \end{bmatrix} \quad n \in \mathbb{Z} \\
\end{aligned}
$$

are stable for even values of $n$ (when the pendulum is hanging down) and unstable for odd values of $n$ (when the pendulum is upright).

We can perturb the original system by adding a small disturbance to the system around the equilibrium points and observe the behavior of the system. In the case of closed circuit, the dynamics stay the same as derived above. However, for open circuit, no current can flow in the circuit, so $i=0$. Therefore, net torque on the motor shaft becomes

$$
\begin{aligned}
T_m &= K_t i - B_m \dot{\theta} - m_p g L_p cos(\theta) \\
&= K_t 0 - B_m \dot{\theta} - m_p g L_p cos(\theta) \\
&= - B_m \dot{\theta} - m_p g L_p cos(\theta) \quad (4)
\end{aligned}
$$

Using the eqution of angular acceleration and torque, we have

$$
\begin{aligned}
T_m &= I_p \ddot{\theta} \\
\text{Substituting for } T_m \text{ from } (4),& \text{ we have} \\
I_p \ddot{\theta} &= - B_m \dot{\theta} - m_p g L_p cos(\theta) \\
\ddot{\theta} &= - \frac{B_m}{I_p} \dot{\theta} - \frac{m_p g L_p}{I_p} cos(\theta) \quad (5)
\end{aligned}
$$

Using the state variables $x_1 = \theta, x_2 = \dot{\theta}$, we have the following state space equations for the open circuit case:

$$
\begin{aligned}
\dot{x_1} &= x_2 \\
\dot{x_2} &= - \frac{B_m}{I_p} x_2 - \frac{m_p g L_p}{I_p} cos(x_1) \\
y &= x_1
\end{aligned}
$$

The system state $\boldsymbol{x}$ were perturbed by a small amount $[0.01, 0.01]^T$
Perturbed dynamics for $\boldsymbol{x}_{eq1} = [\pi/2, 0]^T$ are:

![Closed circuit perturbed dynamics ($\boldsymbol{x}_{eq1}$)](<hw3p2b_closed_circuit_dynamics_(xeq1).svg>){width=50%}
![Open circuit perturbed dynamics ($\boldsymbol{x}_{eq1}$)](<hw3p2b_open_circuit_dynamics_(xeq1).svg>){width=50%}

We know that the equilibrium point $\boldsymbol{x}_{eq1} = [\pi/2, 0]^T$ is unstable, so we see the perturbed
system diverging from this unstable equilibrium point in both cases and slowly stabilizing around the stable equilibrium point $\boldsymbol{x}_{eq2} = [3\pi/2, 0]^T$.
However, the open circuit case does not stabilize within 10 seconds, while the closed circuit case does. This is because the closed circuit case has a damping torque due the back EMF of the motor ($K_t i$) in addition to the viscous friction torque which helps stabilize the system faster.

Perturbed dynamics for $\boldsymbol{x}_{eq2} = [3\pi/2, 0]^T$ are:

![Closed circuit perturbed dynamics ($\boldsymbol{x}_{eq2}$)](<hw3p2b_closed_circuit_dynamics_(xeq2).svg>){width=50%}
![Open circuit perturbed dynamics ($\boldsymbol{x}_{eq2}$)](<hw3p2b_open_circuit_dynamics_(xeq2).svg>){width=50%}

We know that the equilibrium point $\boldsymbol{x}_{eq2} = [3\pi/2, 0]^T$ is stable, so we see the perturbed
system converging to this stable equilibrium point in both cases. However, the open circuit case takes longer to stabilize compared to the closed circuit case. This is because the closed circuit case has a damping torque due the back EMF of the motor ($K_t i$) in addition to the viscous friction torque which helps stabilize the system faster. Even so, the open circuit system only wanders around the stable equilibrium point within the same order of magnitude as the perturbation and does not diverge.
