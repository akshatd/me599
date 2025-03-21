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
This relationship can be used to compute the optimal control law $u^*(k)$ and the optimal cost function value $J^*(x_0)$ recursively, starting from the final time step and working backwards to the initial time step.

Hence, starting at the final timestep $2N$ and going till the timestep $N$, for the sequence $x(N),\ldots,x(2N)$, we have the optimal cost function:

$$
J^*(x(N)) = J_2
$$

For the timestep $k=N-1$, we have:

$$
\begin{aligned}
J^*(x(N-1)) &= \min_{u(N-1)} ( G(x(N-1),u(N-1)) + J^*(x(N)) ) \\
&= \min_{u(N-1)} ( G(x(N-1),u(N-1)) + J_2 ) \\
\text{for k=N-2, we have:} \\
J^*(x(N-2)) &= \min_{u(N-2)} ( G(x(N-2),u(N-2)) + J^*(x(N-1)) ) \\
&= \min_{u(N-2)} ( G(x(N-2),u(N-2)) + G(x(N-1),u(N-1)) + J_2 ) \\
\text{and so on, until we reach k=0} \\
\end{aligned}
$$

Here, we can see that for computing the optimal cost for timesteps $N-1$ to $0$, we need to have already computed the optimal cost for timesteps $N$ to $2N$, which is $J_2$. Therefore, even though we can concatenate the optimal control laws for the two subproblems to get the optimal control law for the entire problem, we need to compute the optimal cost function for the second subproblem first before we can compute the optimal cost function for the first subproblem. This means that the two subproblems cannot be solved in parallel, and my colleague's idea will not work.
