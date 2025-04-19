%% ME599 HW7 Problem 1

clc; clear; close all;

% setup
n = 12; % number of states
m = 4; % number of inputs
Ts = 0.1; % sample time
rng(1); % for reproducibility

% system ID using DMD with control
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