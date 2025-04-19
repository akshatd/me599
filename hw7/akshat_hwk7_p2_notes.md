---
geometry:
  - margin=2cm
---

## Problem 2

### Problem 2.a

We need to identify the discrete-time system in `aerialVehSim.p`, which has been identified as a linear system in Homework 5. We have the state $\boldsymbol{x}$ and control input $\boldsymbol{u}$:

$$
\boldsymbol{x} = \begin{bmatrix}
x \\ y \\ z \\ \dot{x} \\ \dot{y} \\ \dot{z} \\ \phi \\ \theta \\ \psi \\ \dot{\phi} \\ \dot{\theta} \\ \dot{\psi}
\end{bmatrix} \in \mathbb{R}^{12}
,\quad
\boldsymbol{u} = \begin{bmatrix}
u_1 \\ u_2 \\ u_3 \\ u_4
\end{bmatrix} \in \mathbb{R}^{4} \\
\quad n = 12, \quad m = 4
$$

The dynamics are given by the function $F =$ `aerialVehSim.p` in discrete time for the given time step $Ts=0.1$:

$$
\boldsymbol{x}_{k+1} = F(\boldsymbol{x}_k, u_k, Ts)
$$

We will attempt to identify the system by using DMD with control as outlined [here](https://www.youtube.com/watch?v=K-7l0q920io). Given a discrete time system of the form $\boldsymbol{x}_{k+1} = A\boldsymbol{x}_k + B\boldsymbol{u}_k$, we first collect data the system given an initial state $\boldsymbol{x}_0$ and random control inputs ${\boldsymbol{u}_0, \boldsymbol{u}_1, \ldots, u_{N-1}}$ that produce state trajectories ${\boldsymbol{x}_1, \boldsymbol{x}_2, \ldots, \boldsymbol{x}_{N}}$. We can then stack this data into matrices $X, X'$ and $U$:

$$
X = \begin{bmatrix}
\vdots & \vdots & \ldots & \vdots \\
\boldsymbol{x}_0 & \boldsymbol{x}_1 & \ldots & \boldsymbol{x}_{N-1} \\
\vdots & \vdots & \ldots & \vdots
\end{bmatrix} \in \mathbb{R}^{n \times N}
,\quad
X' = \begin{bmatrix}
\vdots & \vdots & \ldots & \vdots \\
\boldsymbol{x}_1 & \boldsymbol{x}_2 & \ldots & \boldsymbol{x}_{N} \\
\vdots & \vdots & \ldots & \vdots
\end{bmatrix} \in \mathbb{R}^{n \times N}
,\quad
U = \begin{bmatrix}
\vdots & \vdots & \ldots & \vdots \\
\boldsymbol{u}_0 & \boldsymbol{u}_1 & \ldots & \boldsymbol{u}_{N-1} \\
\vdots & \vdots & \ldots & \vdots
\end{bmatrix} \in \mathbb{R}^{m \times N}
$$

Such that

$$
\begin{aligned}
X' &= A X + B U \\
&= \begin{bmatrix}
A & B
\end{bmatrix}
\begin{bmatrix}
X \\
U
\end{bmatrix}
\end{aligned}
$$

If $N > n$, we can solve for $A$ and $B$ using the least squares solution of $||X' - \begin{bmatrix} A & B \end{bmatrix} \begin{bmatrix} X \\ U \end{bmatrix}||_F$:

$$
\begin{bmatrix}
A & B
\end{bmatrix} = X' \begin{bmatrix}
X \\ U
\end{bmatrix}^+
$$

Where for a matrix $D$, $D^+$ is the pseudo-inverse of $D$

$$
D^+ = D^T (DD^T)^{-1}
$$

$\pagebreak$

After we have the compound matrix $\begin{bmatrix} A & B \end{bmatrix}$, we can extract $A$ and $B$ by splitting the matrix into two parts, extracting the first $n$ columns as $A$ and the last $m$ columns as $B$. The system was identified as follows:

![A and B matrices of the system](figs/hw7p2_AB.png)

Plotting the actual system against the identified system shows us that the identified system matches the actual system well, hence we can conclude that the system has been identified correctly.

![Comparison of actual and identified system](figs/hw7p2_sysid.svg){width=110%}

$\pagebreak$

### Problem 2.b
