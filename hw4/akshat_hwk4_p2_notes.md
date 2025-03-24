---
geometry:
  - margin=2cm
---

## Problem 2

Given discrete-time system dynamics

$$
x(k+1) = F(x(k),u(k))
$$

and objective function

$$
J = H(x(2N)) + \sum_{k=0}^{2N} G(x(k),u(k))
$$

we need to find the optimal control law $u^*(k)=\phi_k(x(k))$ that minimizes the cost function $J$.
The proposal is to break this subproblem down into two subproblems that can be solved in parallel:

$$
\begin{aligned}
J_1 &= \sum_{k=0}^{N-1} (x(k),u(k)) \\
\text{with the optimal control law } u^*(k) &= A_k(x(k)), k=0,\ldots,N-1 \\
J_2 &= H(x(2N)) + \sum_{k=N}^{2N} G(x(k),u(k)) \\
\text{with the optimal control law } u^*(k) &= B_k(x(k)), k=N,\ldots,2N-1
\end{aligned}
$$

Denoting the optimal cost function value at $x_k$ as $J^*(x_k)$, we can rewrite the cost function using Bellman's principle of optimality:

$$
J^*(x(k)) = \min_{u(k)} ( G(x(k),u(k)) + J^*(x(k+1)) )
$$

where $x(k+1) = F(x(k),u(k))$.
This relationship can be used to compute the optimal control law $u^*(k)$ and the optimal cost function value $J^*(x_0)$ recursively.

For the timestep $k=N-1$, we have:

$$
\begin{aligned}
J^*(x(N-1)) &= \min_{u(N-1)} ( G(x(N-1),u(N-1)) + J^*(x(N)) ) \\
&= \min_{u(N-1)} ( G(x(N-1),u(N-1)) + J^*(F(x(N-1),u(N-1))) ) \\
\end{aligned}
$$

We note that the cost from $N$ to $2N$, for the sequence $x(N),\ldots,x(2N)$, we have the optimal cost function:

$$
J^*(x(N)) = J^*(F(x(N-1),u(N-1))) = J_2
$$

So even though we might have an expression of the the cost function $J_2$ if we solve recursively from $2N$, it will be in terms of $x(N-1)$ and $u(N-1)$. This means that we will not be able to compute the optimal control law $u^*(k)$ for $k=N \dots 2N$ till we have the actual value of $x(N-1)$ and $u(N-1)$.
To determine $x(N-1)$ and $u(N-1)$, we need to solve the problem from $0$ to $N-1$ first, and thus it is NOT POSSIBLE to solve the two subproblems in parallel.
