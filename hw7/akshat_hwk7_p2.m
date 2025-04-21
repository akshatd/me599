%% ME599 HW7 Problem 2

clc; clear; close all;

% setup
n = 12; % number of states
m = 4; % number of inputs
Ts = 0.1; % sample time
rng(1); % for reproducibility

%% part a system ID using DMD with control
N = 500; % number of samples
U = randn(m, N); % input
x_0 = randn(n, 1);

X = zeros(n, N);
X_p1 = zeros(n, N);
x_k = x_0;
for i = 1:N
	X(:, i) = x_k;
	X_p1(:, i) = aerialVehSim(x_k, U(:, i), Ts);
	x_k = X_p1(:, i);
end

AB = X_p1*pinv([X;U]);
A = AB(:, 1:n);
B = AB(:, n+1:end);
format short;
fprintf('HW7 P2: Identified A:\n');
disp(round(A, 3));
fprintf('HW7 P2: Identified B:\n');
disp(round(B, 3));

% check if identified correctly
X_model = zeros(n, N);
X_model(:, 1) = x_0;
for i = 2:N
	X_model(:, i) = A*X_model(:, i-1) + B*U(:, i-1);
end

tspan = (0:N-1)*Ts;
states = ["$x$", "$y$", "$z$", "$\dot{x}$", "$\dot{y}$", "$\dot{z}$", ...
	"$\phi$", "$\theta$", "$\psi$", "$\dot{\phi}$", "$\dot{\theta}$", "$\dot{\psi}$"];
fig = figure;
sgtitle('HW7P2: System ID of aerialVehSim');

for i = 1:n
	subplot(4, 3, i);
	plot(tspan, X(i, :), 'b', 'LineWidth', 2, 'DisplayName', 'Actual');
	hold on;
	plot(tspan, X_model(i, :), 'r--', 'LineWidth', 1.5, 'DisplayName', 'Model');
	xlabel('Time (s)');
	xlim([0 N*Ts]);
	ylabel(states(i), 'Interpreter', 'latex', 'FontSize', 16);
	legend('Location', 'northwest');
end

fig.Position(3:4) = [800 1000];
saveas(fig, 'figs/hw7p2_sysid.svg');

%% part b MPC and LQR control
Tend = 15; % simulation time
tsteps = 0:Ts:Tend;
Nsim = length(tsteps);
N = 30;
tsteps_ref = 0:Ts:Tend*2;
x_ref = zeros(n, length(tsteps_ref));

x_ref(1:3, :) = [
	0.1*sin(tsteps_ref/2);
	0.1*cos(tsteps_ref/2);
	0.1*tsteps_ref;
	];

Q = [10*eye(3), zeros(3, 9);
	zeros(9, 3), zeros(9, 9)];
R = eye(m);

[coeff_MPC, A_bar] = MPCCtrl(A, B, Q, R, N);
K_lqr = dlqr(A, B, Q, R);
x_mpc_all = zeros(n, Nsim);
x_lqr_all = zeros(n, Nsim);
x0 = [0, 0.1, 0, zeros(1, 9)]';
x_mpc = x0;
x_lqr = x0;
for k=1:Nsim
	x_ref_mpc = reshape(x_ref(:, k:k+N-1), [], 1);
	u_mpc = coeff_MPC*(x_ref_mpc - A_bar*x_mpc);
	u_mpc = u_mpc(1:m);
	x_mpc = aerialVehSim(x_mpc, u_mpc, Ts);
	x_mpc_all(:, k) = x_mpc;
	
	u_lqr = -K_lqr*(x_lqr - x_ref(:, k));
	x_lqr = aerialVehSim(x_lqr, u_lqr, Ts);
	x_lqr_all(:, k) = x_lqr;
end

% plot
fig = figure;
plot3(x_mpc_all(1, :), x_mpc_all(2, :), x_mpc_all(3, :), 'r', 'LineWidth', 2, 'DisplayName', 'MPC');
hold on;
plot3(x_lqr_all(1, :), x_lqr_all(2, :), x_lqr_all(3, :), 'b', 'LineWidth', 1.5, 'DisplayName', 'LQR');
plot3(x_ref(1, 1:Nsim), x_ref(2, 1:Nsim), x_ref(3, 1:Nsim), 'k--', 'LineWidth', 1, 'DisplayName', 'Reference');
xlabel("$x$ (m)", 'Interpreter', 'latex', 'FontSize', 16);
ylabel("$y$ (m)", 'Interpreter', 'latex', 'FontSize', 16);
zlabel("$z$ (m)", 'Interpreter', 'latex', 'FontSize', 16);
title('HW7P2: 3D Trajectory of aerial vehicle');
legend('Location', 'best');
fig.Position(3:4) = [500 500];
saveas(fig, 'figs/hw7p2_3d.svg');

fig = figure;
sgtitle('HW7P2: 2D Trajectory of aerial vehicle');
subplot(3, 1, 1);
plot(tsteps, x_mpc_all(1, :), 'r', 'LineWidth', 2, 'DisplayName', 'MPC');
hold on;
plot(tsteps, x_lqr_all(1, :), 'b', 'LineWidth', 1.5, 'DisplayName', 'LQR');
plot(tsteps, x_ref(1, 1:Nsim), 'k--', 'LineWidth', 1, 'DisplayName', 'Reference');
xlabel('Time (s)');
ylabel("$x$ (m)", 'Interpreter', 'latex', 'FontSize', 16);
legend('Location', 'best');

subplot(3, 1, 2);
plot(tsteps, x_mpc_all(2, :), 'r', 'LineWidth', 2, 'DisplayName', 'MPC');
hold on;
plot(tsteps, x_lqr_all(2, :), 'b', 'LineWidth', 1.5, 'DisplayName', 'LQR');
plot(tsteps, x_ref(2, 1:Nsim), 'k--', 'LineWidth', 1, 'DisplayName', 'Reference');
xlabel('Time (s)');
ylabel("$y$ (m)", 'Interpreter', 'latex', 'FontSize', 16);
legend('Location', 'best');

subplot(3, 1, 3);
plot(tsteps, x_mpc_all(3, :), 'r', 'LineWidth', 2, 'DisplayName', 'MPC');
hold on;
plot(tsteps, x_lqr_all(3, :), 'b', 'LineWidth', 1.5, 'DisplayName', 'LQR');
plot(tsteps, x_ref(3, 1:Nsim), 'k--', 'LineWidth', 1, 'DisplayName', 'Reference');
xlabel('Time (s)');
ylabel("$z$ (m)", 'Interpreter', 'latex', 'FontSize', 16);
legend('Location', 'best');

fig.Position(3:4) = [1000 500];
saveas(fig, 'figs/hw7p2_2d.svg');

function [u_coeff, A_bar] = MPCCtrl(A,B,Q,R,N)
nx = size(A,2);
nu = size(B,2);

% initialize matrices
A_bar = zeros(N*nx,nx);
B_bar = zeros(N*nx,N*nu);
Q_bar = zeros(N*nx,N*nx);
R_bar = zeros(N*nu,N*nu);

% Compute first row of A_bar then use it to initialize the rest
A_bar(1:nx,:) = A;
for i = 2:N
	A_bar((i-1)*nx+1 : i*nx, :) = A_bar((i-2)*nx+1:(i-1)*nx,:)*A;
end

% Compute first column of B_bar then use it to initialize the rest
for i = 1:N
	B_bar((i-1)*nx+1 : i*nx, 1:nu) = A^(i-1)*B;
end
for i = 2:N
	zero_rows = (i-1)*nx;
	zero_cols = nu;
	B_bar(:, (i-1)*nu+1 : i*nu) = [zeros(zero_rows,zero_cols); B_bar(1:end-zero_rows, 1:nu)];
end

% Compute Q_bar
for i = 1:N
	Q_bar((i-1)*nx+1 : i*nx, (i-1)*nx+1 : i*nx) = Q;
end

% Compute R_bar
for i = 1:N
	R_bar((i-1)*nu+1 : i*nu, (i-1)*nu+1 : i*nu) = R;
end

u_coeff = inv(B_bar'*Q_bar*B_bar + R_bar)*B_bar'*Q_bar;

end