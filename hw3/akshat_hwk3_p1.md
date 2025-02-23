---
geometry:
  - margin=2cm
---

# ME599 Homework 3 - Akshat Dubey

## Problem 1.a

Let $L \in \mathbb{R}^{n \times n}$ be the Laplacian of a connected undirected graph with no self-loops. Show that the induced $\infty$-norm of $e^{-L}$ is unique, that is, vector $v = \mathbf{1}_n$ is the unique solution of

$$
\max_{\|v\|_\infty = 1} \|e^{-L} v\|_\infty.
$$

## Problem 1.b

Consider the dynamical system:

$$
\dot{x}(t) = A x(t) + B u(t).
$$

Show that for a zero-order hold on the input, that is, $u(t) \equiv u_{k}$ for $t \in [k \Delta t, (k+1) \Delta t)$, $k = 1, 2, \ldots$, the discrete-time system is

$$
x_{k+1} = A_{d} x_{k} + B_{d} u_{k}
$$

where $x_{k} = x(k \Delta t)$,

$$
A_{d} = e^{A \Delta t}, \quad B_{d} = \int_{\tau=0}^{\Delta t} e^{A \tau} B d\tau.
$$

Further, show that, in fact,

$$
\begin{bmatrix}
A_{d} & B_{d} \\
0 & I
\end{bmatrix}
= e^{\begin{bmatrix}
A & B \\
0 & 0
\end{bmatrix} \Delta t}.
$$
