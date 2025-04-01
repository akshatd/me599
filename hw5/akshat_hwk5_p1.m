%% ME599 HW5 Problem 1
clc; clear; close all;

% setup
n = 12; % number of states
m = 4; % number of inputs
Ts = 0.1; % sample time

L = n+1;
extra = 0;
N = (m+1)*L-1 + extra; % total number of samples
mL = m*L; % required rank of Hankel matrix
R = eye(m);

% generate us and Hankel matrix
u = randn(m, N)*5; % input
% u = repmat(0:N-1, m, 1); % test input

HL = zeros(mL, N-L+1);
for i = 1:L
	rowstart = (i-1)*m+1;
	rowend = i*m;
	HL(rowstart:rowend, :) = u(:, i:N-L+i);
end

% check rank of Hankel matrix
if rank(HL) < mL
	error('Hankel matrix is not full rank');
else
	fprintf('Hankel matrix is full rank\n');
end

% generate all N samples
z = zeros(n+m, N);
zopt_kp1 = zeros(n+m, N);
x_k = randn(n,1);
for i = 1:N
	z(1:n, i) = x_k;
	z(n+1:end, i) = u(:, i);
	x_kp1 = aerialVehSim(x_k, u(:, i), Ts);
	zopt_kp1(1:n, i) = x_kp1;
	x_k = x_kp1;
end

% select l samples
l = n+m;
Z = z(:, 1:l);
Zopt = zopt_kp1(:, 1:l);

% check rank of Z
if rank(Z) < l
	error('Z matrix is not full rank');
else
	fprintf('Z matrix is full rank\n');
end

%% part a
Q = 10*eye(n);
Qbar = blkdiag(Q, R);
Kopt = RLLQR(n, m, Qbar, Z, Zopt);

% simulate using the optimal control gain matrix
Tend = 10; % simulation time
tsteps = 0:Ts:Tend;
x_all = zeros(n, length(tsteps));
x_k = [1; -1; 0; 0.5; -1; 1; 0; 0; 0; 0; 0; 0];

for i=1:length(tsteps)
	x_all(:, i) = x_k;
	u_k = -Kopt * x_k;
	x_kp1 = aerialVehSim(x_k, u_k, Ts);
	x_k = x_kp1;
end

% plot results
fig = figure;
plot(tsteps, x_all(1, :), 'LineWidth', 2, 'DisplayName', "$x$");
hold on;
plot(tsteps, x_all(2, :), 'LineWidth', 2, 'DisplayName', "$y$");
plot(tsteps, x_all(3, :), 'LineWidth', 2, 'DisplayName', "$z$");
ylabel("Position");
xlabel("Time (s)");
legend('Interpreter', 'latex', 'FontSize', 12, 'Location', 'best');
title("HW5 P1a: Position trajectories with Optimal Control Gain Matrix");
saveas(fig, "figs/hw5p1a_pos.svg");

fig = figure;
plot(tsteps, x_all(4, :), 'LineWidth', 2, 'DisplayName', "$\dot{x}$");
hold on;
plot(tsteps, x_all(5, :), 'LineWidth', 2, 'DisplayName', "$\dot{y}$");
plot(tsteps, x_all(6, :), 'LineWidth', 2, 'DisplayName', "$\dot{z}$");
ylabel("Velocity");
xlabel("Time (s)");
title("HW5 P1a: Velocity trajectories with Optimal Control Gain Matrix");
legend('Interpreter', 'latex', 'FontSize', 12, 'Location', 'best');
saveas(fig, "figs/hw5p1a_vel.svg");

%% part b
% only penalize position
Q = blkdiag(10*eye(3), zeros(n-3, n-3));
Qbar = blkdiag(Q, R);
Kopt = RLLQR(n, m, Qbar, Z, Zopt);

% simulate using the optimal control gain matrix
Tend = 15; % simulation time
tsteps = 0:Ts:Tend;
x_all = zeros(n, length(tsteps));
x_ref = zeros(n, length(tsteps));
x_ref(1:3, :) = [
	0.1*sin(tsteps/2);
	0.1*cos(tsteps/2);
	0.1*tsteps;
	];
x_k = x_ref(:, 1);

for i=1:length(tsteps)
	x_all(:, i) = x_k;
	u_k = -Kopt * (x_k - x_ref(:, i));
	x_kp1 = aerialVehSim(x_k, u_k, Ts);
	x_k = x_kp1;
end

% plot results
fig = figure;
plot3(x_ref(1, :), x_ref(2, :), x_ref(3, :), '--', 'LineWidth', 2, 'DisplayName', "Desired");
hold on;
plot3(x_all(1, :), x_all(2, :), x_all(3, :), 'LineWidth', 2, 'DisplayName', "Actual");
xlabel("x");
ylabel("y");
zlabel("z");
title("HW5 P1b: Desired vs actual maneuver position trajectories");
legend('Location', 'best');
saveas(fig, "figs/hw5p1b_pos.svg");

function Kopt = RLLQR(n, m, Qbar, Z, Zopt)
% iterate and find theta matrix
K_i = zeros(m, n);

for i=1:1000
	Zopt(n+1:end, :) = -K_i * Zopt(1:n, :);
	theta_ip1 = dlyap(Z', -Z'*Qbar*Z, [], Zopt');
	% theta_ip1 = dlyap(Zopt', Z'*Qbar*Z, [], Z'); % alternative
	K_ip1 = inv(theta_ip1(n+1:end, n+1:end)) * theta_ip1(n+1:end, 1:n);
	
	% check convergence
	fprintf('Iteration %d: norm(K_i - K_ip1) = %f\n', i, norm(K_i - K_ip1));
	if norm(K_ip1 - K_i) < 1e-6
		fprintf('Converged after %d iterations\n', i);
		break;
	end
	
	K_i = K_ip1;
end
Kopt = K_i;
end