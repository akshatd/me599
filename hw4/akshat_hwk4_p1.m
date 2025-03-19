%% ME599 HW4 Problem 1
clc; clear; close all;

%% part a, proving operator G is linear
% Load example voltage as V1
load('V_example.mat');
V1 = V_example;
N = length(V1);
tspan = 0.1*(1:N)'; % transpose so row vector

% generate some weird shit as V2
V2 = (sin(tspan)+1) * max(V1)/4; % scale to be half the height as V1
V2(173:end) = 0; % zeros after last full sine wave

a1 = -0.23;
a2 = 1.14;
V12 = a1*V1+a2*V2;

% plot input voltages
fig = figure;
plot(tspan, V1, LineWidth=1.5, DisplayName='$V_1$');
hold on;
plot(tspan, V2, LineWidth=1.5, DisplayName='$V_2$');
plot(tspan, V12, '--', LineWidth=1.5, DisplayName='$a_1V_1+a_2V_2$')
ylabel('$V(V)$', 'Interpreter', 'latex')
ylim([-1 41]);
xlabel('$t(\mu s)$', 'Interpreter', 'latex')
legend('Location', 'best', 'Interpreter', 'latex');
title("HW4P1a: Input Voltages");
saveas(fig, 'figs/hw4p1a_volts.svg');

% get outputs for all possible inputs
P1 = piezo_nozzle(V1, N);
P2 = piezo_nozzle(V2, N);
P12 = piezo_nozzle(V12, N);
P12_alt = a1*P1 + a2*P2;

% plot outputs
fig = figure;
plot(tspan, P1, LineWidth=1.5, DisplayName='$P_1$');
hold on;
plot(tspan, P2, LineWidth=1.5, DisplayName='$P_2$');
plot(tspan, P12, LineWidth=1.5, DisplayName='$P_{12}$');
plot(tspan, P12_alt, '--', LineWidth=1.5, DisplayName='$P_a$');
ylabel('$P(kPa)$', 'Interpreter', 'latex');
xlabel('$t(\mu s)$', 'Interpreter', 'latex')
legend('Location', 'best', 'Interpreter', 'latex');
title("HW4P1a: Output Pressure");
saveas(fig, 'figs/hw4p1a_press.svg');

%% part b, designing an ILC controller

load('P_ref.mat');
max_iters = 10000;
learn_rate = 0.5;
tol = 1e-6;
V = zeros(N,1); % initial guess
tau = flip(eye(N)); % flipping matrix

i = 0;
while true
	% get the error
	e = P_ref - piezo_nozzle(V, N);
	% get the cost
	J = 0.5 * (e' * e);
	% get the gradient
	grad = tau * piezo_nozzle(tau*e, N);
	% update the guess
	V = V + learn_rate * grad;
	% print results
	if mod(i, 100) == 0
		fprintf("Iteration %d: J = %f, grad = %f\n", i, J, norm(grad));
	end
	
	% check for convergence
	if norm(grad) < 1e-6
		fprintf("Norm of gradient reached tolerance criteria");
		break;
	end
	i = i + 1;
	if i > max_iters
		fprintf("Max iterations reached\n");
		break;
	end
end

fprintf("Converged after %d iterations\n", i);

P_opt = piezo_nozzle(V, N);

% plot the result
fig = figure;
yyaxis left;
hold on;
plot(tspan, P_opt, '-b', LineWidth=1.5, DisplayName='$\mathcal{G}(V^*)$');
plot(tspan, P_ref, '--g', LineWidth=1.5, DisplayName='$P_{ref}$');
ylabel('$P(kPa)$', 'Interpreter', 'latex');
yyaxis right;
plot(tspan, V, LineWidth=1.5, DisplayName='$V^*$');
ylabel('$V(V)$', 'Interpreter', 'latex');
xlabel('$t(\mu s)$', 'Interpreter', 'latex');
legend('Location', 'best', 'Interpreter', 'latex');
title("HW4P1b: ILC Controller");
saveas(fig, 'figs/hw4p1b.svg');

% plot the error
fig = figure;
plot(tspan, P_ref - P_opt, LineWidth=1.5);
ylabel('$e(kPa)$', 'Interpreter', 'latex');
hold on;
xlabel('$t(\mu s)$', 'Interpreter', 'latex');
title("HW4P1b: ILC Error");
saveas(fig, 'figs/hw4p1b_error.svg');
