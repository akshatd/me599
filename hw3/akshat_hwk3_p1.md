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

### Solution

- The infinity norm of a vector $v$, $\|v\|_{\infty}$: Maximum absolute value of the largest element in the vector.
- The expression $\max_{\|v\|_\infty = 1} \|e^{-L} v\|_\infty$ means: Find the vector $v$ with infinity norm equal to 1, such that the infinity norm of the product $e^{-L} v$ is maximized. Hence, no element in the vector $v$ can be greater than 1 in magnitude, and at least one element must be equal to 1 in magnitude.
- The Laplacian matrix $L$ is used to describe the connectivity of a graph, where each row $i$ describes how node the time derivative of node $i$ is affected by other nodes. If there is no edge between a node $i$ and node $j$, then $L_{ij} = 0$.

<!-- Using eigen decomposition, the Laplacian for an undirected graph can also be written as

$$
L=B \Lambda B^{-1}
$$

where $B$ is the orthogonal matrix of eigenvectors of $L$, and $\Lambda$ is a diagonal matrix with the eigenvalues of $L$. Since $B$ is orthogonal, $B^{-1} = B^T$, so

$$
L = B \Lambda B^T
$$

$\Lambda$ can also be thought of as a diagonal matrix containing all the weights of the edges in the graph and $B$ is the incidence matrix with entries:

$$
B_{i,k} = \begin{cases}
-1 & \text{if edge $k$ starts at node $i$}, \\
1 & \text{if edge $k$ ends at node $i$}, \\
0 & \text{otherwise}.
\end{cases}
$$ -->

From the notes 4.2 page 6, we know that $L \vec{1} = \vec{0}$, which is similar to the general form of an eigenvalue problem, $L v = \lambda v$. This suggests that the smallest eigenvalue of $L$ is 0, and the corresponding eigenvector is $\vec{1}$.

[Expanding the expression](https://en.wikipedia.org/wiki/Matrix_exponential) $e^{-L} v$, where $v = \vec{1}$:

$$
\begin{aligned}
e^{-L} v = e^{-L} \vec{1} &= \left(I-L+\frac{L^2}{2!}-\frac{L^3}{3!}+\ldots\right) \vec{1} \\
&= \left(I \vec{1} - L \vec{1} + \frac{L^2}{2!} \vec{1} - \frac{L^3}{3!} \vec{1} + \ldots\right) \\
&= \left(\vec{1} - \vec{0} + \vec{0} + \vec{0} + \ldots\right) \text{all terms with an $L\vec{1}=0$} \\
&= \vec{1}
\end{aligned}
$$

Since $\|\vec{1}\|_{\infty} = 1$, $v = \vec{1}$ is a solution to the optimization problem, where the objective $\|e^{-L} v\|_{\infty} = 1$.

To prove that it is a unique solution, we need to show that no other vector $v$, where $\|v\|_{\infty} = 1$, can have a larger $\|e^{-L} v\|_{\infty}$ than 1. From the notes 4.2 page 6, we know that if $L$ describes an unconnected directed graph, $e^{-L}$ is row-stochastic, which means that the sum of the elements in each row is 1. The matrix product $e^{-L} v$ sums up each row of $e^{-L}$ weighted by the corresponding element in $v$. A vector $v' \neq \vec{1}$ that has $\|\vec{v}\|_{\infty}=1$ will have at least one element $< 1$. Let

$$
\begin{aligned}
e^{-L} &= E \\
v &= [v_1, v_2, \ldots, v_n]^T \\
e^{-L} v &= E v \\
\text{Then} \\
e^{-L} v &= \begin{bmatrix}
E_{1,1} & E_{1,2} & \ldots & E_{1,n} \\
E_{2,1} & E_{2,2} & \ldots & E_{2,n} \\
\vdots & \vdots & \ddots & \vdots \\
E_{n,1} & E_{n,2} & \ldots & E_{n,n}
\end{bmatrix}
\begin{bmatrix}
v_1 \\
v_2 \\
\vdots \\
v_n
\end{bmatrix} \\
&= \begin{bmatrix}
E_{1,1} v_1 + E_{1,2} v_2 + \ldots + E_{1,n} v_n \\
E_{2,1} v_1 + E_{2,2} v_2 + \ldots + E_{2,n} v_n \\
\vdots \\
E_{n,1} v_1 + E_{n,2} v_2 + \ldots + E_{n,n} v_n
\end{bmatrix}
\end{aligned}
$$

When $v = \vec{1}$,

$$
\begin{aligned}
e^{-L} v &= \begin{bmatrix}
E_{1,1} + E_{1,2} + \ldots + E_{1,n} \\
E_{2,1} + E_{2,2} + \ldots + E_{2,n} \\
\vdots \\
E_{n,1} + E_{n,2} + \ldots + E_{n,n}
\end{bmatrix} \\
&= \begin{bmatrix}
1 \\
1 \\
\vdots \\
1
\end{bmatrix}
\end{aligned}
$$

If we have $v'$ such that $v'_i < 1$ for some $i$, then

$$
\begin{aligned}
e^{-L} v' &= \begin{bmatrix}
E_{1,1} v'_1 + \ldots + E_{1,i} v'_i + \ldots + E_{1,n} v'_n \\
E_{2,1} v'_1 + \ldots + E_{2,i} v'_i + \ldots + E_{2,n} v'_n \\
\vdots \\
E_{n,1} v'_1 + \ldots + E_{n,i} v'_i + \ldots + E_{n,n} v'_n
\end{bmatrix} \\
&= \begin{bmatrix}
E_{1,1} + \ldots + E_{1,i} v'_i + \ldots + E_{1,n} \\
E_{2,1} + \ldots + E_{2,i} v'_i + \ldots + E_{2,n} \\
\vdots \\
E_{n,1} + \ldots + E_{n,i} v'_i + \ldots + E_{n,n}
\end{bmatrix}
\end{aligned}
$$

Since for any $X$, $\|X\|_{\infty} = \max_{i} |X_i|$, when comparing $e^{-L} \vec{1}$ and $e^{-L} v'$, row by row with subtraction, we see that for each row $j$ of $e^{-L}v'$ and $e^{-L} \vec{1}$, $|(e^{-L}v')_j| - |(e^{-L} \vec{1})_j| < 0 \implies \|e^{-L} v'\|_{\infty} < \|e^{-L} \vec{1}\|_{\infty}$.

$$
\begin{aligned}
&(|E_{j,1} + \ldots + E_{j,i} v'_i + \ldots + E_{j,n}|) - (|E_{j,1} + \ldots + E_{j,n}|) \\
&= |E_{j,1}| - |E_{j,1}| + \ldots + |E_{j,i} v'_i| - |E_{j,i}| + \ldots + |E_{j,n}| - |E_{j,n}| \\
&= |E_{j,i} v'_i| - |E_{j,i}| \\
&< 0
\end{aligned}
$$

Since $v_i < 1$ will scale down the element $E_{j,i}$. Hence $v = \vec{1}$ is the unique solution to the optimization problem with the constraint $\|v\|_{\infty} = 1$.

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
