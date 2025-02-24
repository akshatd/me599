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

### Solution

We are given that

$$
\begin{aligned}
\dot{x}(t) &= A x(t) + B u(t) \\
x_k &= x(k \Delta t) \\
\Delta t &= \text{integration time step}
\end{aligned}
$$

And we know that

$$
\begin{aligned}
\frac{\partial}{\partial t} e^{A t} &= A e^{A t} \\
\frac{\partial}{\partial t} (e^{-A t} x(t)) &= e^{-A t} \dot{x}(t) - A e^{-A t} x(t) \text{ (product rule)}
\end{aligned}
$$

Rearranging the equation, we get $\dot{x}(t) - A x(t) = B u(t)$. Then multiplying by $e^{-A t}$ on both sides

$$
\begin{aligned}
e^{-A t} \dot{x}(t) - A e^{A t} x(t) &= e^{-A t} B u(t) \\
\frac{\partial}{\partial t} (e^{-A t} x(t)) &= e^{-A t} B u(t) \\
\end{aligned}
$$

Integrating both sides from $k \Delta t$ to $(k+1) \Delta t$:

$$
\begin{aligned}
\int_{t=k \Delta t}^{(k+1) \Delta t} \frac{\partial}{\partial t} (e^{-A t} x(t)) dt &= \int_{t=k \Delta t}^{(k+1) \Delta t} e^{-A t} B u(t) dt \\
\end{aligned}
$$

Simplifying the LHS

$$
\begin{aligned}
e^{-A (k+1) \Delta t} x((k+1) \Delta t) - e^{-A k \Delta t} x(k \Delta t) &= \int_{t=k \Delta t}^{(k+1) \Delta t} e^{-A t} B u(t) dt \\
\end{aligned}
$$

Applying the zero order hold assumption $u(t) = u_k \text{ for } t \in [k \Delta t, (k+1) \Delta t)$, we get

$$
\begin{aligned}
e^{-A (k+1) \Delta t} x((k+1) \Delta t) - e^{-A k \Delta t} x(k \Delta t) &= \left(\int_{t=k \Delta t}^{(k+1) \Delta t} e^{-A t} B dt\right) u_k \\
\end{aligned}
$$

Substituting $\tau = t - k \Delta t$ such that

$$
\begin{aligned}
& t = k \Delta t + \tau, dt = d\tau \\
& \text{when } t = k \Delta t, \tau = 0 \\
& \text{when } t = (k+1) \Delta t, \tau = \Delta t \\
\end{aligned}
$$

We get

$$
\begin{aligned}
e^{-A (k+1) \Delta t} x((k+1) \Delta t) - e^{-A k \Delta t} x(k \Delta t) &= \left(\int_{\tau=0}^{\Delta t} e^{-A (k \Delta t + \tau)} B d\tau\right) u_k \\
e^{-A (k+1) \Delta t} x((k+1) \Delta t) - e^{-A k \Delta t} x(k \Delta t) &= e^{-A k \Delta t} \left(\int_{\tau=0}^{\Delta t} e^{-A \tau} B d\tau\right) u_k \\
e^{-A (k+1) \Delta t} x((k+1) \Delta t) &= e^{-A k \Delta t} x(k \Delta t) + e^{-A k \Delta t} \left(\int_{\tau=0}^{\Delta t} e^{-A \tau} B d\tau\right) u_k \\
\end{aligned}
$$

Multiply both sides by $e^{A (k+1) \Delta t}$ to isolate $x((k+1) \Delta t)$

$$
\begin{aligned}
x((k+1) \Delta t) &= e^{A (k+1) \Delta t} \left(e^{-A k \Delta t} x(k \Delta t) + e^{-A k \Delta t} \left(\int_{\tau=0}^{\Delta t} e^{-A \tau} B d\tau\right) u_k\right) \\
x((k+1) \Delta t) &= e^{A \Delta t} x(k \Delta t) + e^{A \Delta t} \left(\int_{\tau=0}^{\Delta t} e^{-A \tau} B d\tau\right) u_k \\
\end{aligned}
$$

$e^{-A \tau}$ can be written as $e^{-A \tau} = e^{A(\Delta t - \tau)}e^{-A\Delta t}$, where $e^{-A\Delta t}$ is a constant. Hence

$$
\begin{aligned}
x((k+1) \Delta t) &= e^{A \Delta t} x(k \Delta t) + e^{A \Delta t} \left(\int_{\tau=0}^{\Delta t} e^{A(\Delta t - \tau)}e^{-A\Delta t} B d\tau\right) u_k \\
x((k+1) \Delta t) &= e^{A \Delta t} x(k \Delta t) + e^{A \Delta t} e^{-A\Delta t} \left(\int_{\tau=0}^{\Delta t} e^{A(\Delta t - \tau)} B d\tau\right) u_k \\
x((k+1) \Delta t) &= e^{A \Delta t} x(k \Delta t) + \left(\int_{\tau=0}^{\Delta t} e^{A(\Delta t - \tau)} B d\tau\right) u_k \\
\end{aligned}
$$

Substituting $\tau' = \Delta t - \tau$ such that

$$
\begin{aligned}
d\tau' &= -d\tau \quad \text{differentiating both sides with } \tau \\
\text{when } & \tau = 0, \tau' = \Delta t \\
\text{when } & \tau = \Delta t, \tau' = 0 \\
\end{aligned}
$$

We get

$$
\begin{aligned}
x((k+1) \Delta t) &= e^{A \Delta t} x(k \Delta t) + \left(\int_{\tau'=\Delta t}^{0} e^{A \tau'} B (-d\tau')\right) u_k \\
\end{aligned}
$$

Where we can flip the limits of integration to get

$$
\begin{aligned}
x((k+1) \Delta t) &= e^{A \Delta t} x(k \Delta t) + \left(\int_{\tau'=0}^{\Delta t} e^{A \tau'} B d\tau'\right) u_k \\
\end{aligned}
$$

Renaming $\tau'$ back to $\tau$, since it is just a dummy variable, and using the definition $x_k = x(k \Delta t)$, we get

$$
\begin{aligned}
x_{k+1} &= e^{A \Delta t} x_k + \left(\int_{\tau=0}^{\Delta t} e^{A \tau} B d\tau\right) u_k \\
\end{aligned}
$$

Hence, the discrete-time system is

$$
x_{k+1} = A_{d} x_{k} + B_{d} u_{k}
$$

where

$$
A_{d} = e^{A \Delta t}, \quad B_{d} = \int_{\tau=0}^{\Delta t} e^{A \tau} B d\tau
$$

For the second part of the question, we start with the definition of a matrix exponential of some matrix $X \Delta t$

$$
\begin{aligned}
e^{X \Delta t} &= I + X \Delta t + \frac{(X \Delta t)^2}{2!} + \frac{(X \Delta t)^3}{3!} + \ldots \\
&= \sum_{n=0}^{\infty} \frac{(X \Delta t)^n}{n!}
\end{aligned}
$$

Let $X = \begin{bmatrix} A & B \\ 0 & 0 \end{bmatrix}$, then observing powers of $X$ in the matrix exponential, we have

$$
\begin{aligned}
X^2 &= \begin{bmatrix}
A & B \\
0 & 0
\end{bmatrix} \begin{bmatrix}
A & B \\
0 & 0
\end{bmatrix} = \begin{bmatrix}
A^2 & AB \\
0 & 0
\end{bmatrix} \\
X^3 &= \begin{bmatrix}
A & B \\
0 & 0
\end{bmatrix} \begin{bmatrix}
A^2 & AB \\
0 & 0
\end{bmatrix} = \begin{bmatrix}
A^3 & A^2B \\
0 & 0
\end{bmatrix} \\
X^n &= \begin{bmatrix}
A^n & A^{n-1}B \\
0 & 0
\end{bmatrix}
\end{aligned}
$$

Then, the $e^{X \Delta t}$ can be written as

$$
\begin{aligned}
e^{X \Delta t} &= I + \begin{bmatrix}
A & B \\
0 & 0
\end{bmatrix} \Delta t + \frac{1}{2!} \begin{bmatrix}
A^2 & AB \\
0 & 0
\end{bmatrix} (\Delta t)^2 + \ldots \\
&= \begin{bmatrix}
I + A \Delta t + \frac{A^2 (\Delta t)^2}{2!} + \ldots & B \Delta t + \frac{AB (\Delta t)^2}{2!} + \ldots \\
0 & I
\end{bmatrix} \text{ ( The identity matrix adds an identity to the bottom right corner)} \\ \\
&= \begin{bmatrix}
\sum_{n=0}^{\infty} \frac{A^n (\Delta t)^n}{n!} & \sum_{n=1}^{\infty} \frac{A^{n-1}B (\Delta t)^n}{n!} \\
0 & I
\end{bmatrix} \\
&= \begin{bmatrix}
e^{A \Delta t} & \sum_{n=1}^{\infty} \frac{A^{n-1}B (\Delta t)^n}{n!} \\
0 & I
\end{bmatrix} \text{ ( using the definition of matrix exponential)} \\
&= \begin{bmatrix}
e^{A \Delta t} & \sum_{n=1}^{\infty} \frac{A^{n-1} (\Delta t)^n}{n!} B \\
0 & I
\end{bmatrix} \text{ ( rearranging the terms)}
\end{aligned}
$$

Using the definition of [matrix exponential integrals](https://math.stackexchange.com/questions/658276/integral-of-matrix-exponential)

$$
\begin{aligned}
\int_{\tau=0}^{\Delta t} e^{A \tau} d \tau &= (e^{A \Delta t} - I) A^{-1} \\
&= \left(\sum_{n=0}^{\infty} \frac{A^n (\Delta t)^n}{n!} - I\right) A^{-1} \\
&= \left(I + A \Delta t + \frac{A^2 (\Delta t)^2}{2!} + \ldots - I\right) A^{-1} \\
&= \left(A \Delta t + \frac{A^2 (\Delta t)^2}{2!} + \ldots\right) A^{-1} \text{ ( cancelling the identity terms)} \\
&= \left(\Delta t + \frac{A (\Delta t)^2}{2!} + \ldots\right) \text{ ( dividing the $A$ terms)} \\
&= \sum_{n=1}^{\infty} \frac{A^{n-1} (\Delta t)^n}{n!}
\end{aligned}
$$

We can rewrite $e^{X \Delta t}$ as

$$
\begin{aligned}
e^{X \Delta t} &= \begin{bmatrix}
e^{A \Delta t} & \sum_{n=1}^{\infty} \frac{A^{n-1} (\Delta t)^n}{n!} B \\
0 & I
\end{bmatrix} \\
&= \begin{bmatrix}
e^{A \Delta t} & \int_{\tau=0}^{\Delta t} e^{A \tau} B d\tau \\
0 & I
\end{bmatrix} \\
&= \begin{bmatrix}
A_d & B_d \\
0 & I
\end{bmatrix}
\end{aligned}
$$

Where $A_d = e^{A \Delta t}$ and $B_d = \int_{\tau=0}^{\Delta t} e^{A \tau} B d\tau$ as defined in the problem. Hence, we have shown that

$$
\begin{bmatrix}
A_{d} & B_{d} \\
0 & I
\end{bmatrix}
= e^{\begin{bmatrix}
A & B \\
0 & 0
\end{bmatrix} \Delta t}
$$
