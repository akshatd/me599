%% ME599 HW7 Problem 1

clc; clear; close all;

load('fox_hare.mat');

x = hare; y = fox; xy = hare.*fox;
x_cum = cumtrapz(x);
y_cum = cumtrapz(y);
xy_cum = cumtrapz(xy);
n = length(x);
% construct matrices A and b
A = zeros(n*2, 4);
b = zeros(n*2, 1);
for i = 1:n
	row = 2*i-1;
	
	A(row, :) = [x_cum(i), -xy_cum(i), 0, 0];
	A(row+1, :) = [0, 0, -y_cum(i), xy_cum(i)];
	
	b(row) = x(i) - x(1);
	b(row+1) = y(i) - y(1);
end

% solution
theta = A\b;
alpha = theta(1); beta = theta(2); gamma = theta(3); delta = theta(4);
fprintf("HW7P1: least squares solution:\n - alpha: %f\n - beta: %f\n - gamma: %f\n - delta: %f\n", alpha, beta, gamma, delta);
fprintf("HW7P1: least squares error: %f\n", norm(A*theta - b));

% simulate and plot system
tspan = 1:1:n;
[t, x_ode] = ode45(@(t, x) LotkaVolterra(t, x, 0, theta), 1:0.1:n, [x(1); y(1)]);
fig = figure;
sgtitle('HW7P1: Identified Lotka-Volterra Model');
subplot(2, 1, 1);
plot(t, x_ode(:, 1), 'r', 'Linewidth', 1.5, 'DisplayName', 'Hares (Model)')
hold on;
scatter(tspan, x, 'xb', 'DisplayName', 'Hares (Data)');
ylabel('Population');
title('Hare Population');
legend('Location', 'northeast');

subplot(2, 1, 2);
plot(t, x_ode(:, 2), 'r', 'Linewidth', 1.5, 'DisplayName', 'Foxes (Model)')
hold on;
scatter(tspan, y, 'xb', 'DisplayName', 'Foxes (Data)');
xlabel('Time (months)');
ylabel('Population');
title('Fox Population');
legend('Location', 'northeast');
fig.Position(3:4) = [1000 500];
saveas(fig, 'figs/hw7p1_model.svg');

%% linearize around equilibrium
x_e = gamma/delta;
y_e = alpha/beta;
fprintf("HW7P1: Equilibrium point:\n - x_e: %f\n - y_e: %f\n", x_e, y_e);

Ac = [
	alpha-beta*y_e, -beta*x_e;
	delta*y_e, -gamma+delta*x_e
	];
Bc = [0; 1];
[Ad, Bd, ~, ~] = c2dm(Ac, Bc, [], [], 1, 'zoh');

eigA = eig(Ad);
fprintf("HW7P1: Eigenvalues of discrete-time system:\n");
disp(eigA);
if abs(eigA(1)) <= 1 && abs(eigA(2)) <= 1
	fprintf(" - System is stable\n");
else
	fprintf(" - System is unstable\n");
end

% setup LQR controller
Q = [10 0;
	0 1];
R = 2;
[K, ~, ~] = dlqr(Ad, Bd, Q, R);

% simulate closed-loop system
k_end = 10; % number of months to simulate
x0s = [
	30, 20, 35;
	15, 25, 10;
	];
for i=1:size(x0s, 2)
	x0 = x0s(:, i);
	x_k = x0;
	x_history = zeros(2, k_end);
	u_history = zeros(k_end, 1);
	for k = 1:k_end
		x_history(:, k) = x_k;
		x_kdelta = round(x_k - [30; y_e]);
		u_k = round(-K*x_kdelta);
		u_history(k) = u_k;
		[~, x_ode] = ode45(@(t, x) LotkaVolterra(t, x, u_k, theta), k:k+1, x_k);
		x_k = round(x_ode(end, :)');
	end
	
	% plot closed-loop system
	fig = figure;
	sgtitle("HW7P1: Optimal population control from " + x0(1) + " hares, " + x0(2) + " foxes");
	subplot(2, 1, 1);
	plot(x_history(1, :), 'b', 'Linewidth', 1.5, 'DisplayName', 'Hares');
	hold on;
	yline(x_e(1), 'k--', 'DisplayName', ' Desired Hares');
	ylabel('Population');
	title('Hare Population');
	legend('Location', 'northeast');
    ylim([20 40]);
	
	subplot(2, 1, 2);
	yyaxis left;
	plot(x_history(2, :), 'b', 'Linewidth', 1.5, 'DisplayName', 'Foxes');
	ylabel('Population');
    ylim([5 25]);
	hold on;
	yyaxis right;
	plot(u_history, 'DisplayName', 'Foxes brought in or sold');
	ylabel('Population change');
    ylim([-10 15]);
	xlabel('Time (months)');
	title('Fox Population');
	legend('Location', 'northeast');
	
	saveas(fig, "figs/hw7p1_control_"+x0(1)+".svg");
end
function xdot = LotkaVolterra(~, x, u, theta)
alpha = theta(1);
beta = theta(2);
gamma = theta(3);
delta = theta(4);

xdot = zeros(2, 1);
xdot(1) = alpha*x(1) - beta*x(1)*x(2);
xdot(2) = -gamma*x(2) + delta*x(1)*x(2) + u;
end